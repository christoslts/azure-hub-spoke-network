# How to Upload Your Hub-Spoke Project to GitHub (Web UI)

This guide uses GitHub's web interface — **no command line needed!**

## Step 1: Create the Repository (2 minutes)

1. Go to https://github.com/christoslts (your GitHub profile)
2. Click **"+"** icon (top right) → **"New repository"**
3. Fill in:
   - **Repository name:** `azure-hub-spoke-network`
   - **Description:** `Production-ready hub-and-spoke VNet architecture with Terraform`
   - **Visibility:** Public ✓
   - **Initialize with:** 
     - ✓ Add a README file
     - ✓ Add .gitignore (select "Terraform")
     - ✓ Choose a license (select "MIT")
4. Click **"Create repository"**

## Step 2: Add Files (5-10 minutes)

### Method A: Upload via Web UI (Easiest)

1. You're now in your repo. Click **"Add file"** → **"Upload files"**

2. **Copy the content** of each file below, then:
   - Create the file in your text editor (VS Code, Notepad++)
   - Save with the exact filename
   - Drag and drop into GitHub's upload area

### Method B: Create Files Directly (Also Easy)

1. Click **"Add file"** → **"Create new file"**

2. **File 1: `main.tf`**
   - Name: `main.tf`
   - Content: [See FILE CONTENT BELOW]
   - Commit message: "feat: add hub and spoke VNets with NSGs"

3. **File 2: `peering.tf`**
   - Name: `peering.tf`
   - Content: [See FILE CONTENT BELOW]
   - Commit message: "feat: add VNet peering configuration"

4. **File 3: `variables.tf`**
   - Name: `variables.tf`
   - Content: [See FILE CONTENT BELOW]
   - Commit message: "feat: add input variables"

5. **File 4: `outputs.tf`**
   - Name: `outputs.tf`
   - Content: [See FILE CONTENT BELOW]
   - Commit message: "feat: add output values"

6. **File 5: `terraform.tfvars`**
   - Name: `terraform.tfvars`
   - Content: [See FILE CONTENT BELOW]
   - Commit message: "config: add terraform variables"

7. **File 6: README.md** (Update the auto-created one)
   - Click on README.md (in repo) → Click pencil icon
   - Delete all content
   - Paste the new README content
   - Commit message: "docs: add comprehensive README"

## Step 3: Verify Upload

1. Go to your repo: https://github.com/christoslts/azure-hub-spoke-network
2. You should see:
   - 6 files listed (main.tf, peering.tf, variables.tf, outputs.tf, terraform.tfvars, LICENSE, .gitignore, README.md)
   - Green checkmarks (no errors)
   - README displayed at bottom

## Step 4: Add Repository Topics (Makes it searchable)

1. Click **"⚙️ Settings"** (top right of repo)
2. Scroll down to **"Topics"**
3. Add these tags:
   - `azure`
   - `terraform`
   - `infrastructure-as-code`
   - `cloud`
   - `networking`
4. Click **"Save changes"**

## Step 5: Enable GitHub Pages (Optional, for nice portfolio effect)

1. Still in Settings
2. Scroll to **"GitHub Pages"**
3. **Source:** Branch → main
4. **Folder:** /root
5. Click **"Save"**
6. Your README is now at: `https://christoslts.github.io/azure-hub-spoke-network`

## Verify Everything Works

### Test Locally (Optional)

If you have Terraform installed, you can test the code:

```bash
# Clone your repo
git clone https://github.com/christoslts/azure-hub-spoke-network.git
cd azure-hub-spoke-network

# Check Terraform syntax
terraform init
terraform validate

# Expected output: "Success! The configuration is valid."
```

### Check GitHub Interface

Your repo should show:
- ✅ All files visible
- ✅ README renders at bottom
- ✅ No syntax errors
- ✅ Topics showing (azure, terraform, etc.)
- ✅ Green checkmarks on all files

## Troubleshooting

### ❌ "File already exists"

If you're uploading and GitHub says file exists:
- Click **"Cancel"** → Delete the old file first → Upload again

### ❌ "Large file"

Terraform files are small (~5 KB each), so this shouldn't happen. If it does:
- Make sure you're not uploading `.tfstate` files (they're in .gitignore)

### ❌ README not showing

- You must have a file named exactly `README.md` (case-sensitive)
- The file must be in the root directory (not in a folder)

## Next: Create Project 2 & 3

Once Project 1 is live:

1. **Create repo:** `azure-landing-zone-governance`
2. **Create repo:** `terraform-azure-pipeline`

(I'll provide the code for these next)

---

## Quick File Reference

Here are the filenames you need to create:

```
azure-hub-spoke-network/
├── README.md           ← Update the auto-created one
├── main.tf             ← Create new
├── peering.tf          ← Create new
├── variables.tf        ← Create new
├── outputs.tf          ← Create new
├── terraform.tfvars    ← Create new
├── .gitignore          ← GitHub creates this, but verify it has terraform rules
└── LICENSE             ← GitHub creates this, verify it's MIT
```

---

**Total time: ~15 minutes for all files**

Once complete, reply with a link to your repo and I'll:
1. ✅ Verify everything is correct
2. ✅ Create Project 2 files
3. ✅ Create Project 3 files
4. ✅ Write your LinkedIn post templates
