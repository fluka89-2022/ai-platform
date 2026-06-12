#!/usr/bin/env python3
"""
Publish approved GitLab issue drafts from .md files.

Usage:
    python publish_issues.py <input.json>

Input JSON format:
    {
      "issues": [
        "docs/gitlab/2026-06-12-add-api-key.md",
        "docs/gitlab/2026-06-12-store-hashed-keys.md"
      ]
    }

Each .md file must have YAML frontmatter with at least: title, type, labels.
Optional frontmatter fields: milestone, parent_story.
"""

import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

import yaml


def parse_md(path: Path) -> tuple[dict, str]:
    text = path.read_text()
    match = re.match(r"^---\n(.*?)\n---\n(.*)", text, re.DOTALL)
    if not match:
        raise ValueError(f"No YAML frontmatter in {path}")
    fm = yaml.safe_load(match.group(1))
    body = match.group(2).strip()
    return fm, body


def slugify(title: str, max_words: int = 5) -> str:
    words = re.sub(r"[^a-z0-9\s]", "", title.lower()).split()
    return "-".join(words[:max_words])


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return result.stdout.strip()


def get_story_branch(parent_story_id: int) -> str:
    output = run(["glab", "issue", "view", str(parent_story_id), "--output", "json"])
    issue = json.loads(output)
    slug = slugify(issue["title"], max_words=5)
    return f"story/{parent_story_id}-{slug}"


def detect_base_branch() -> str:
    try:
        output = run(["git", "branch", "-r"])
        for line in output.splitlines():
            if "origin/develop" in line.strip():
                return "develop"
    except subprocess.CalledProcessError:
        pass
    return "main"


def update_frontmatter(path: Path, fm: dict, body: str) -> None:
    content = "---\n" + yaml.dump(fm, default_flow_style=False, allow_unicode=True) + "---\n\n" + body + "\n"
    path.write_text(content)


def publish_issue(md_path: Path) -> dict:
    fm, body = parse_md(md_path)

    title = fm["title"]
    labels = fm.get("labels", "")
    milestone = fm.get("milestone", "")
    parent_story = fm.get("parent_story")

    if parent_story:
        try:
            base_branch = get_story_branch(int(parent_story))
        except Exception as e:
            print(f"  ! Could not resolve story branch for #{parent_story}: {e}. Falling back to default.", file=sys.stderr)
            base_branch = detect_base_branch()
    else:
        base_branch = detect_base_branch()

    cmd = ["glab", "issue", "create", "--title", title, "--description", body]
    if labels:
        cmd += ["--label", labels]
    if milestone:
        cmd += ["--milestone", milestone]

    output = run(cmd)

    url_match = re.search(r"https?://\S+?/(\d+)$", output, re.MULTILINE)
    if not url_match:
        raise ValueError(f"Could not extract issue URL from glab output:\n{output}")
    issue_url = url_match.group(0)
    issue_id = url_match.group(1)

    branch_name = f"task/{issue_id}-{slugify(title)}"

    run(["git", "checkout", "-b", branch_name, base_branch])
    run(["git", "push", "-u", "origin", branch_name])

    if parent_story:
        project_id = run(["glab", "api", "projects/:id", "--jq", ".id"])
        run([
            "glab", "api", "--method", "POST",
            f"projects/:id/issues/{issue_id}/links",
            "-f", f"target_project_id={project_id}",
            "-f", f"target_issue_iid={parent_story}",
            "-f", "link_type=relates_to",
        ])

    fm["status"] = "published"
    fm["gitlab_url"] = issue_url
    fm["branch"] = branch_name
    fm["published_at"] = str(date.today())
    update_frontmatter(md_path, fm, body)

    return {"file": str(md_path), "issue_url": issue_url, "branch": branch_name, "base_branch": base_branch}


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: python publish_issues.py <input.json>", file=sys.stderr)
        sys.exit(1)

    data = json.loads(Path(sys.argv[1]).read_text())
    results, errors = [], []

    for file_path in data["issues"]:
        path = Path(file_path)
        print(f"Publishing {path.name}...", flush=True)
        try:
            result = publish_issue(path)
            results.append(result)
            print(f"  ✓ {result['issue_url']} — branch: {result['branch']} (base: {result['base_branch']})")
        except Exception as e:
            errors.append({"file": file_path, "error": str(e)})
            print(f"  ✗ {file_path}: {e}", file=sys.stderr)

    print(f"\nDone: {len(results)} published, {len(errors)} failed.")
    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
