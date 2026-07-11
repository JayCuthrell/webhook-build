# ⚡ Webhook Build & CI/CD Pipeline for fudge.org

A lightweight, automated CI/CD deployment pipeline tailored for Ubuntu/Linode VPS hosting. This repository manages continuous integration and automated builds for the [fudge.org](https://fudge.org) Eleventy (11ty) static site generator, integrating seamlessly with GitHub pushes and Sveltia CMS edits.

---

## 🌟 Key Features

* **⚡ Instant Automated Deployments:** Listens for GitHub webhooks via `adnanh/webhook` on port `9999` and automatically pulls, builds, and deploys the static site.
* **🛑 "Kill & Replace" Debouncing:** Rapid, sequential saves from Sveltia CMS or VS Code will automatically terminate in-progress or outdated builds. This prevents process stacking, CPU spikes, and out-of-memory errors on the VPS.
* **🔒 Zero-Plaintext Secrets:** Uses Go template evaluation to securely inject the GitHub Webhook secret at runtime from a locked-down local `.env` file (`chmod 600`), keeping sensitive keys out of version control.
* **🧹 Child Process Sweeping:** Cleanly identifies and terminates orphaned Eleventy (`build:11ty`) and Pagefind (`pagefind --site`) child processes before starting a clean build.
* **📝 Dedicated Build Logging:** All standard output and execution errors are automatically routed to a persistent `deploy.log` file for painless real-time debugging.

---

## 📂 Repository Structure

```text
webhook-build/
├── deploy.sh       # Zsh deployment script with debounce & process cleanup
├── hooks.json      # adnanh/webhook configuration file with Go template secrets
├── .gitignore      # Excludes logs, PID files, and local environment secrets
└── README.md       # Project documentation
