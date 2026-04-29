# iPhone/iPad Git Sync Setup for Obsidian using GitSync

These instructions explain how to connect an Obsidian vault on iOS to a GitHub repository and **manually sync** changes using the **GitSync** app (a mobile Git client for iOS/iPadOS).

GitSync replaces the older Working Copy workflow for many users.

**Last updated:** 2025–2026 workflow (based on current GitSync capabilities)

## What you need

- Obsidian installed on iPhone or iPad
- A GitHub account
- A GitHub repository (can create one during setup)
- GitSync app from the App Store

## Step-by-step setup

### 1. Create a GitHub Repository (if you don't have one)

1. Go to github.com and sign in
2. Click **+ → New repository**
3. Give it a name (e.g. `Obsidian-Notes`)
4. Choose **Private** or **Public**
5. Recommended: check **Add a README file**
6. Click **Create repository**

### 2. Create a temporary vault in Obsidian on iOS

1. Open **Obsidian**
2. Tap **Create new vault**
3. Give it the same name as your GitHub repo (or something recognizable)
4. Skip any sync setup prompts
5. Create one test note (e.g. `Test.md`) → this helps you identify the folder later

### 3. (Recommended) Use a separate mobile config folder

To prevent desktop plugin/workspace settings from breaking mobile:

1. In Obsidian → **Settings → Files and links → Override config folder**
2. Set it to: `.obsidian.mobile` (or similar, must start with .)

This is still considered best practice even with GitSync.

### 4. Install GitSync

- Download **GitSync** from the App Store
- Open the app

### 5. Complete GitSync initial setup

1. Tap **Let’s Go**
2. Allow notifications (optional – useful for sync reminders)
3. Finish the onboarding screens

### 6. Sign in to GitHub (easiest method: OAuth)

1. Choose **GitHub** authentication
2. Tap **OAuth**
3. Sign in via the browser that opens
4. When prompted, enter your **commit author name** and **email**  
   (used for commits made from GitSync)

### 7. Clone the repository

#### Option A: Direct clone into the Obsidian vault folder (recommended when it works)

1. In GitSync, select your GitHub repository from the list 
2. When asked **where to clone**, browse to: - the Obsidian vault folder you created in step 2 (usually under On My iPhone → Obsidian → YourVaultName) 
3. Confirm you're in the right folder (you should see your `Test.md` note) 
4. When prompted, choose **Overwrite** → This replaces the temporary vault files with the content from GitHub

After cloning finishes, the vault folder is now also a Git repository. Proceed to step 8.

**Note:** If the clone fails, aborts, shows permission errors, or doesn't properly integrate (some users report intermittent folder access quirks on iOS), use **Option B** below instead.

#### Option B: Clone to a separate folder, then move to Obsidian (workaround for tricky cases)

1. In the iOS **Files** app, create a new folder somewhere easy to access (e.g. On My iPhone → GitSyncTemp or directly under On My iPhone) 
2. In GitSync: - Select your GitHub repository - Choose this new/temporary folder as the clone destination - Let it clone fully (no overwrite prompt here since it's empty/new) 
3. Once cloned, go back to the **Files** app: - Navigate to the cloned folder (it now contains your repo files + hidden `.git`) - Long-press the folder → **Copy** (or **Move**) - Go to: On My iPhone → Obsidian - Paste/move it here (you can overwrite/replace the temporary vault folder from step 2 if it has the same name, or rename for clarity) 
4. . If needed, rename the moved folder to match your desired vault name 
5. The folder is now in Obsidian's expected location and is a full Git repo

Proceed to step 8.

### 8. Open the vault in Obsidian

1. Go back to Obsidian 
2. If you used Option A: Open the existing vault (it should now show GitHub contents) 
3. If you used Option B: Tap **Open folder as vault** (or create/open if renamed), then select the moved/cloned folder 
4. Verify your notes appear correctly

### 9. How to sync changes (manual workflow)

**Simplest method** – use the **Sync Changes** button:

1. Make edits in Obsidian (create/edit/delete notes)
2. Open **GitSync**
3. Tap **Sync Changes**  
   → GitSync automatically handles commit + push (and pull if needed)

**More control** – switch to **Client Mode**:

- Open GitSync → switch to **Client Mode**
- Use individual actions:
  - Fetch / Pull (get changes from GitHub)
  - Stage files
  - Commit
  - Push

### 10. Optional: Background / scheduled sync

GitSync supports scheduled automatic sync on iOS. This feature is currently behind a paywall.

- Check GitSync settings or documentation
- Enable scheduled sync if you want less manual work  
  (still recommended to occasionally check manually)

## Important warnings

- **Disable Obsidian Git plugin on mobile**  
  If you use the **Obsidian Git** plugin on desktop → turn it **off** on iOS for this vault.  
  It conflicts with GitSync. Follow step 3 for mobile specific config.

- Do **not** let Obsidian auto-create vaults inside iCloud/Google Drive/OneDrive when using GitSync — keep everything in "On My iPhone/iPad".

## Quick summary (10 steps)

1. Create GitHub repo (if needed)
2. In Obsidian iOS: create vault + add test note
3. (Recommended) Set `.obsidian.mobile` config folder
4. Install GitSync
5. Complete onboarding
6. Sign in with GitHub OAuth
7. Select repo → clone into the vault folder
8. Allow **overwrite** of temporary files
9. Open vault in Obsidian
10. Sync manually with **Sync Changes** (or Client Mode)

Happy syncing!