import os
import glob
from PIL import Image, ImageDraw, ImageFilter, ImageFont

# Define target dimensions for App Store
IPAD_SIZE = (2064, 2752)       # 13" iPad (Portrait)
DESKTOP_SIZE = (2560, 1600)    # Mac Desktop (16:10 Landscape)

# Brand colors
BRAND_PRIMARY = (35, 50, 99)       # #233263
BRAND_LIGHT_BG_START = (227, 233, 255) # #E3E9FF
BRAND_LIGHT_BG_MID = (249, 250, 253)   # #F9FAFD
BRAND_LIGHT_BG_END = (232, 227, 227)   # #E8E3E3

# Dark premium theme colors
DARK_BG_START = (10, 15, 30)       # Deep rich slate dark
DARK_BG_END = (25, 35, 65)         # Brand navy dark

# Resolve paths dynamically relative to the script directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)

FONT_BOLD_PATH = os.path.join(PROJECT_ROOT, "assets", "fonts", "Inter_18pt-Bold.ttf")
FONT_REGULAR_PATH = os.path.join(PROJECT_ROOT, "assets", "fonts", "Inter_18pt-Regular.ttf")

TITLE_MAPPINGS = {
    "login": ("Teacher Login", "Access your portal securely using OTP verification"),
    "attendance": ("Mark Attendance", "Track and manage student attendance in real-time"),
    "home": ("Teacher Dashboard", "All your tasks, classes, and schedules in one place"),
    "profile": ("My Profile", "Manage your personal profile and preferences"),
    "notification": ("Stay Updated", "Receive instant school notifications and alerts"),
    "device": ("Device Authentication", "Secure login linked directly to your device"),
}

def crop_status_and_home_indicator(img):
    """
    Crops out the native iOS status bar and home indicator
    to make the screenshot look professional and ready for App Store.
    """
    w, h = img.size
    # Standard iOS status bar is ~5.5% of height
    # Home indicator is ~4% of height at the bottom
    top_crop = int(h * 0.055)
    bottom_crop = int(h * 0.04)
    
    # Crop box: (left, upper, right, lower)
    cropped_img = img.crop((0, top_crop, w, h - bottom_crop))
    return cropped_img

def get_gradient_background(size, colors):
    """Creates a smooth linear gradient background."""
    base = Image.new("RGB", size)
    draw = ImageDraw.Draw(base)
    
    num_colors = len(colors)
    if num_colors == 2:
        c1, c2 = colors
        for y in range(size[1]):
            t = y / (size[1] - 1)
            r = int(c1[0] * (1 - t) + c2[0] * t)
            g = int(c1[1] * (1 - t) + c2[1] * t)
            b = int(c1[2] * (1 - t) + c2[2] * t)
            draw.line([(0, y), (size[0], y)], fill=(r, g, b))
    elif num_colors == 3:
        c1, c2, c3 = colors
        mid = size[1] // 2
        for y in range(mid):
            t = y / (mid - 1)
            r = int(c1[0] * (1 - t) + c2[0] * t)
            g = int(c1[1] * (1 - t) + c2[1] * t)
            b = int(c1[2] * (1 - t) + c2[2] * t)
            draw.line([(0, y), (size[0], y)], fill=(r, g, b))
        for y in range(mid, size[1]):
            t = (y - mid) / (size[1] - mid - 1)
            r = int(c2[0] * (1 - t) + c3[0] * t)
            g = int(c2[1] * (1 - t) + c3[1] * t)
            b = int(c2[2] * (1 - t) + c3[2] * t)
            draw.line([(0, y), (size[0], y)], fill=(r, g, b))
            
    return base

def draw_device_mockup(canvas, screenshot_path, center_x, center_y, target_height):
    """Draws an ultra-premium device mockup with shadow, metallic bezel, and clean glass reflection."""
    try:
        raw_shot = Image.open(screenshot_path)
    except Exception as e:
        print(f"Error opening screenshot {screenshot_path}: {e}")
        return

    # Clean the screenshot (remove status bar and home indicator)
    shot = crop_status_and_home_indicator(raw_shot)

    # Calculate screenshot dimensions
    aspect_ratio = shot.width / shot.height
    shot_h = target_height
    shot_w = int(shot_h * aspect_ratio)
    
    # Resize screenshot
    shot = shot.resize((shot_w, shot_h), Image.Resampling.LANCZOS)
    
    # Premium Bezel layout
    bezel = 14
    corner_radius = 42
    
    phone_w = shot_w + (bezel * 2)
    phone_h = shot_h + (bezel * 2)
    
    # 1. Outer Soft Ambient Glow & Shadow
    shadow_offset = 20
    shadow_blur = 35
    shadow_mask = Image.new("L", (phone_w + shadow_blur * 2, phone_h + shadow_blur * 2), 0)
    shadow_draw = ImageDraw.Draw(shadow_mask)
    shadow_draw.rounded_rectangle(
        [shadow_blur, shadow_blur, shadow_blur + phone_w, shadow_blur + phone_h],
        radius=corner_radius,
        fill=140 # High quality dark shadow
    )
    shadow_mask = shadow_mask.filter(ImageFilter.GaussianBlur(shadow_blur))
    
    shadow_layer = Image.new("RGBA", shadow_mask.size, (0, 0, 0, 255))
    canvas.paste(
        shadow_layer, 
        (center_x - phone_w // 2 - shadow_blur, center_y - phone_h // 2 - shadow_blur + shadow_offset), 
        mask=shadow_mask
    )
    
    # 2. Outer Bezel (Sleek Space Gray Frame with Metallic Polish)
    bezel_layer = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    bezel_draw = ImageDraw.Draw(bezel_layer)
    
    # Draw metallic outer rim
    bezel_draw.rounded_rectangle(
        [0, 0, phone_w, phone_h],
        radius=corner_radius,
        fill=(15, 15, 18, 255),
        outline=(85, 90, 105, 255), # Steel border highlight
        width=3
    )
    
    # Draw inner black bezel screen border
    bezel_draw.rounded_rectangle(
        [3, 3, phone_w - 3, phone_h - 3],
        radius=corner_radius - 2,
        fill=(8, 8, 10, 255),
        outline=(30, 30, 32, 255),
        width=2
    )
    
    # 3. Paste Cropped Screenshot
    shot_mask = Image.new("L", (shot_w, shot_h), 0)
    shot_draw = ImageDraw.Draw(shot_mask)
    shot_draw.rounded_rectangle(
        [0, 0, shot_w, shot_h],
        radius=max(0, corner_radius - bezel),
        fill=255
    )
    bezel_layer.paste(shot, (bezel, bezel), mask=shot_mask)
    
    # 4. Premium Dynamic Island
    island_w = int(shot_w * 0.28)
    island_h = 24
    island_x = (phone_w - island_w) // 2
    island_y = bezel + 12
    # Draw dynamic island body
    bezel_draw.rounded_rectangle(
        [island_x, island_y, island_x + island_w, island_y + island_h],
        radius=island_h // 2,
        fill=(0, 0, 0, 255)
    )
    # Subtle inner camera lens reflect (adds ultra-realism)
    bezel_draw.ellipse(
        [island_x + island_w - 30, island_y + 6, island_x + island_w - 18, island_y + 18],
        fill=(10, 20, 40, 255),
        outline=(20, 35, 60, 255),
        width=1
    )
    
    # 5. Simulated Status Bar Icons (Clean, white/dark icons depending on theme)
    # Rather than copying the ugly original status bar, we overlay a clean, modern status bar
    try:
        status_font = ImageFont.truetype(FONT_REGULAR_PATH, 16)
    except IOError:
        status_font = ImageFont.load_default()
        
    # Draw a clean simulated time and icons inside the bezel screen area
    # (Just basic text for time and battery, which looks very neat)
    bezel_draw.text((bezel + 28, bezel + 14), "9:41", fill=(30, 30, 30, 255), font=status_font)
    bezel_draw.text((phone_w - bezel - 70, bezel + 14), "📶 🔋", fill=(30, 30, 30, 255), font=status_font)
    
    # 6. Subtle Glass Reflection Highlight (Linear gradient reflection)
    # Creates that diagonal glass sheen across the screen
    glass_layer = Image.new("RGBA", (shot_w, shot_h), (0, 0, 0, 0))
    glass_draw = ImageDraw.Draw(glass_layer)
    # Draw a diagonal polygon with low opacity white
    glass_draw.polygon(
        [(0, 0), (shot_w // 2, 0), (0, shot_h)],
        fill=(255, 255, 255, 12) # ~5% opacity white
    )
    bezel_layer.paste(glass_layer, (bezel, bezel), mask=shot_mask)

    # Paste the complete phone onto the canvas
    canvas.paste(bezel_layer, (center_x - phone_w // 2, center_y - phone_h // 2), mask=bezel_layer)

def add_labels(canvas, filename, is_dark_theme):
    """Adds beautiful title and subtitle text on top."""
    title, subtitle = "Smart AIG Teacher Portal", "Manage attendance and tasks effortlessly"
    lower_fn = filename.lower()
    for kw, (t, s) in TITLE_MAPPINGS.items():
        if kw in lower_fn:
            title, subtitle = t, s
            break
            
    # Text colors
    title_color = (255, 255, 255) if is_dark_theme else BRAND_PRIMARY
    subtitle_color = (180, 190, 220) if is_dark_theme else (90, 95, 115)
    
    draw = ImageDraw.Draw(canvas)
    
    # Load fonts
    try:
        title_font_ipad = ImageFont.truetype(FONT_BOLD_PATH, 76)
        subtitle_font_ipad = ImageFont.truetype(FONT_REGULAR_PATH, 38)
        title_font_desk = ImageFont.truetype(FONT_BOLD_PATH, 68)
        subtitle_font_desk = ImageFont.truetype(FONT_REGULAR_PATH, 34)
    except IOError:
        title_font_ipad = subtitle_font_ipad = title_font_desk = subtitle_font_desk = ImageFont.load_default()
        print("Warning: Inter fonts not loaded. Using default system font.")

    w, h = canvas.size
    
    if h > w: # iPad (Portrait)
        # Title
        t_w = draw.textlength(title, font=title_font_ipad)
        draw.text(((w - t_w) // 2, 240), title, fill=title_color, font=title_font_ipad)
        # Subtitle
        s_w = draw.textlength(subtitle, font=subtitle_font_ipad)
        draw.text(((w - s_w) // 2, 345), subtitle, fill=subtitle_color, font=subtitle_font_ipad)
    else: # Desktop (Landscape)
        # Centered layout on top
        t_w = draw.textlength(title, font=title_font_desk)
        draw.text(((w - t_w) // 2, 110), title, fill=title_color, font=title_font_desk)
        s_w = draw.textlength(subtitle, font=subtitle_font_desk)
        draw.text(((w - s_w) // 2, 195), subtitle, fill=subtitle_color, font=subtitle_font_desk)

def generate_screenshots_for_file(img_path, out_dir):
    filename = os.path.basename(img_path)
    print(f"\nProcessing screenshot: {filename}")
    
    # Generate iPad portrait screenshots (Light & Dark themes)
    for theme in ["light", "dark"]:
        canvas_ipad = get_gradient_background(
            IPAD_SIZE, 
            [DARK_BG_START, DARK_BG_END] if theme == "dark" else [BRAND_LIGHT_BG_START, BRAND_LIGHT_BG_MID, BRAND_LIGHT_BG_END]
        )
        # Draw phone device in the lower center
        draw_device_mockup(canvas_ipad, img_path, IPAD_SIZE[0] // 2, 1600, target_height=1800)
        # Add labels
        add_labels(canvas_ipad, filename, is_dark_theme=(theme == "dark"))
        
        # Save output to Desktop
        out_name = os.path.join(out_dir, f"ipad_{theme}_{os.path.splitext(filename)[0]}.png")
        canvas_ipad.save(out_name)
        print(f"Saved: {out_name}")

    # Generate Desktop landscape screenshots (Light & Dark themes)
    for theme in ["light", "dark"]:
        canvas_desk = get_gradient_background(
            DESKTOP_SIZE, 
            [DARK_BG_START, DARK_BG_END] if theme == "dark" else [BRAND_LIGHT_BG_START, BRAND_LIGHT_BG_MID, BRAND_LIGHT_BG_END]
        )
        # Draw phone device in the center-bottom
        draw_device_mockup(canvas_desk, img_path, DESKTOP_SIZE[0] // 2, 980, target_height=1100)
        # Add labels
        add_labels(canvas_desk, filename, is_dark_theme=(theme == "dark"))
        
        # Save output to Desktop
        out_name = os.path.join(out_dir, f"desktop_{theme}_{os.path.splitext(filename)[0]}.png")
        canvas_desk.save(out_name)
        print(f"Saved: {out_name}")

def main():
    target_dir = "/Users/sjsolutionsandinfotech/Desktop"
    
    # Process the user's uploaded login screenshot
    source_img = "/Users/sjsolutionsandinfotech/Documents/GitHub/teacher_app_attendance/screenshots/login_screen.png"
    if os.path.exists(source_img):
        generate_screenshots_for_file(source_img, target_dir)
        print("\nAll App Store screenshots successfully processed and copied to Desktop!")
    else:
        print(f"Error: Source screenshot not found at {source_img}")

if __name__ == "__main__":
    main()
