# ChooseNDel 🗑️📸

**ChooseNDel** is a lightweight, zero-dependency visual media culling and batch deletion tool designed specifically for **macOS**. It combines native macOS Automator Quick Actions, Bash scripting, and a responsive, browser-based media grid to allow users to quickly review, inspect, select, and delete large batches of images and videos.

---

## 🌟 Key Features

- **⚡ Zero Dependencies:** Runs purely using native macOS tools (`Bash`, `osascript`, `open`) and your default web browser.
- **🖼️ Comprehensive Format Support:**
  - **Images:** `.jpg`, `.jpeg`, `.png`, `.bmp`, `.gif`, `.tiff`, `.heif`
  - **Videos:** `.mp4`, `.webm`, `.ogg`
- **🎛️ Responsive Grid & Customization:**
  - Dynamic column count slider (1 to 10 items per row).
  - Container width slider (30% to 100%).
  - One-click background theme switcher (Dark / Light mode).
  - Smart scroll retention that preserves viewport position during layout changes.
- **🎬 Instant Video Preview:** Autoplays muted videos on hover and pauses on mouse leave, with a global mute/unmute toggle.
- **🔍 Fullscreen Modal Preview:** Detailed high-res preview mode with full keyboard arrow navigation (`Left` / `Right`).
- **⌨️ Productive Keyboard & Mouse Controls:**
  - **Click:** Toggle selection for deletion.
  - **Ctrl + Mouse Hover:** Continuous mass-selection by simply hovering over media.
  - **Shift + Click:** Open high-resolution full-screen modal view.
  - **Cmd + A:** Select all files.
  - **R + V:** Invert current selection.
  - **PageDown / Z:** Scroll down one row.
  - **PageUp / A:** Scroll up one row.
  - **D + L:** Export selected filenames to `___del.txt`.
  - **Escape:** Close fullscreen preview modal.

---

## 🚀 Installation & Setup

1. Clone or download this repository:
   ```bash
   git clone https://github.com/nimabhk/ChooseNDel.git
   ```
2. Double-click `choose n del v1.4.workflow` to install it as a **macOS Quick Action / Service**.
3. Grant necessary permissions for `Automator` and `Finder` under **System Settings > Privacy & Security > Accessibility / Automation** if prompted.

---

## 📖 How to Use

The workflow operates in a simple **two-phase cycle**:

```
[Target Folder] ---> (Quick Action) ---> [Interactive Web Gallery]
                                                  |
                                            (Select & Download)
                                                  v
[Deleted Files] <--- (Quick Action) <--- [___del.txt in Folder]
```

### Step 1: Generate Gallery & Review
1. Right-click on any folder containing images or videos in **Finder**.
2. Navigate to **Quick Actions** and select **Choose & Del**.
3. A local interactive HTML gallery (`___.html`) will automatically open in your default browser alongside a summary dialog showing file counts and folder size.

### Step 2: Select & Export
1. Click on media items to mark them with a **red border** (selected for deletion).
2. Use keyboard shortcuts or top toolbar buttons to refine your selection.
3. Click **Download Selected Files** (or press `D + L`) to generate and download `___del.txt`.

### Step 3: Confirm & Delete
1. Move the downloaded `___del.txt` file into the target image/video folder.
2. Right-click the folder and trigger **Choose & Del** again.
3. Confirm the deletion prompt. The selected media files and temporary workspace files will be removed.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.
