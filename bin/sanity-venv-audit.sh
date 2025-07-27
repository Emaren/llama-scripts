#!/usr/bin/env python3
import os, subprocess, filecmp, socket

IS_VPS = not socket.gethostname().startswith("Mac") and not os.path.expanduser("~").startswith("/Users/")
HOME = os.path.expanduser("~")
REMOTE = "wolo"

def p(path): return path.replace(f"{HOME}/", "") if path.startswith(HOME) else path

repos = {
    "local-staging": {
        "app-staging": f"{HOME}/projects/app-staging",
        "api-staging": f"{HOME}/projects/api-staging",
        "explorer-staging": f"{HOME}/projects/explorer-staging",
        "wolo-staging": f"{HOME}/projects/wolo-staging",
    },
    "local-prod": {
        "app-prod": f"{HOME}/projects/app-prod",
        "api-prod": f"{HOME}/projects/api-prod",
        "app_prodf": f"{HOME}/projects/app_prodf",
        "api-prodf": f"{HOME}/projects/api-prodf",
        "app-prodn": f"{HOME}/projects/app-prodn",
        "api-prodn": f"{HOME}/projects/api-prodn",
        "explorer-prod": f"{HOME}/projects/explorer-prod",
        "wolo-prod": f"{HOME}/projects/wolo-prod",
    },
    "vps-staging": {
        "app-staging": "/var/www/app-staging",
        "api-staging": "/var/www/api-staging",
        "explorer-staging": "/var/www/explorer-staging",
        "wolo-staging": "/var/www/wolo-staging",
    },
    "vps-prod": {
        "app-prod": "/var/www/app-prod",
        "api-prod": "/var/www/api-prod",
        "app_prodf": "/var/www/app_prodf",
        "api-prodf": "/var/www/api-prodf",
        "app-prodn": "/var/www/app-prodn",
        "api-prodn": "/var/www/api-prodn",
        "explorer-prod": "/var/www/explorer-prod",
        "wolo-prod": "/var/www/wolo-prod",
    },
}

def git_status(path):
    if not os.path.exists(path):
        return f"{p(path)} ❌ Not found"
    try:
        os.chdir(path)
        branch = subprocess.check_output(["git", "branch", "--show-current"], text=True).strip()
        status = subprocess.check_output(["git", "status", "--short"], text=True).strip()
        try:
            ahead, behind = map(int, subprocess.check_output(
                ["git", "rev-list", "--left-right", "--count", f"{branch}...origin/{branch}"],
                text=True, stderr=subprocess.DEVNULL).strip().split())
        except: ahead, behind = "?", "?"
        dirty = "Yes" if status else "No"
        return f"{p(path)} [{branch}] ✅ Ahead: {ahead}, Behind: {behind}, Dirty: {dirty}"
    except Exception as e:
        return f"{p(path)} ❌ Error: {e}"

def local_sync(a, b):
    if not os.path.exists(a) or not os.path.exists(b): return "❌ Not found"
    try:
        cmp = filecmp.dircmp(a, b, ignore=[".git", "__pycache__"])
        return "🟢 In sync" if not (cmp.left_only or cmp.right_only or cmp.diff_files) else "🟡 Not in sync"
    except Exception as e: return f"⚠️ {e}"

def remote_sync(local, remote_host, remote):
    try:
        out = subprocess.run(
            ["rsync", "-avcn", "--delete", local + "/", f"{remote_host}:{remote}/"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=10
        ).stdout
        return "🟡 Not in sync" if any(l.startswith(("<f", ">f", "*deleting")) or "deleting" in l for l in out.splitlines()) else "🟢 In sync"
    except subprocess.TimeoutExpired as e: return f"⏳ Timeout after {e.timeout}s"
    except Exception as e: return f"❌ {e}"

def main():
    for scope, mapping in repos.items():
        print(f"\n🔍 {scope.upper().replace('-', ' ')} REPOS")
        for _, path in mapping.items():
            if not IS_VPS and path.startswith("/var/www"):
                print(f" • {path} ❌ Not found")
            else:
                print(" •", git_status(path))

        if scope == "local-prod":
            print(f"\n🔁 LOCAL STAGING ⇄ PROD SYNC CHECK")
            sync_pairs = [("app",), ("api",), ("explorer",), ("wolo",)]
            for name in sync_pairs:
                a = repos["local-prod"].get(f"{name[0]}-prod")
                b = repos["local-staging"].get(f"{name[0]}-staging")
                if a and b:
                    print(f" • Local: {p(a):<30} ⇄ Local: {p(b):<30} {local_sync(a, b)}")

        if scope.endswith("prod") and scope.startswith("vps"):
            print(f"\n🔁 VPS STAGING ⇄ PROD SYNC CHECK")
            for name in repos["vps-staging"]:
                a = repos["vps-prod"].get(name)
                b = repos["vps-staging"].get(name)
                if a and b:
                    print(f" • VPS: {a:<30} ⇄ VPS: {b:<30} {local_sync(a, b)}")

    print(f"\n🔁 PROD ⇄ LOCAL SYNC CHECK (Manual Additions)")
    manual = [
        ("app_prodf", f"{HOME}/projects/app_prodf", "/var/www/app_prodf"),
        ("api-prodf", f"{HOME}/projects/api-prodf", "/var/www/api-prodf"),
        ("app-prodn", f"{HOME}/projects/app-prodn", "/var/www/app-prodn"),
        ("api-prodn", f"{HOME}/projects/api-prodn", "/var/www/api-prodn"),
    ]
    for _, local, remote in manual:
        print(f" • {p(local):<30} ⇄ {REMOTE}:{remote:<30} {remote_sync(local, REMOTE, remote)}")

if __name__ == "__main__":
    main()
