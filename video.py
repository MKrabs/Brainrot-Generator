import os
import sys
from moviepy.editor import (
    ImageClip, TextClip, CompositeVideoClip,
    AudioFileClip
)


def resolve_asset(filename, input_dir, default_dir):
    """Return the path to the file, preferring input_dir, falling back to default_dir."""
    input_path = os.path.join(input_dir, filename)
    default_path = os.path.join(default_dir, filename)

    if os.path.isfile(input_path):
        return input_path
    elif os.path.isfile(default_path):
        print(f"[INFO] Using default for missing file: {filename}")
        return default_path
    else:
        raise FileNotFoundError(f"Missing required asset: {filename}")


def create_video(input_folder, default_folder="default_assets"):
    try:
        # Ensure input exists
        if not os.path.isdir(input_folder):
            raise NotADirectoryError(f"Provided path is not a folder: {input_folder}")

        # Resolve assets
        background_path = resolve_asset("background.jpg", input_folder, default_folder)
        overlay_path = resolve_asset("overlay.png", input_folder, default_folder)
        audio_path = resolve_asset("audio.mp3", input_folder, default_folder)
        title_path = os.path.join(input_folder, "title.txt")
        title_text = open(title_path).read().strip() if os.path.isfile(title_path) else "Untitled Video"

        # Constants
        duration = 15
        resolution = (1080, 1920)

        # Background image
        bg_clip = (ImageClip(background_path)
                   .resize(height=resolution[1])
                   .set_duration(duration)
                   .set_position("center"))

        # Title
        title_clip = (TextClip(title_text, fontsize=100, color='white', font='Arial-Bold')
                      .set_duration(duration)
                      .set_position(("center", "top"))
                      .margin(top=100, opacity=0))

        # Overlay
        overlay_clip = (ImageClip(overlay_path, transparent=True)
                        .resize(height=resolution[1])
                        .set_duration(duration)
                        .set_position("center"))

        # Audio
        audio_clip = AudioFileClip(audio_path).subclip(0, duration)

        # Final video
        video = CompositeVideoClip([bg_clip, title_clip, overlay_clip], size=resolution)
        video = video.set_audio(audio_clip)

        output_path = os.path.join(input_folder, "final_video.mp4")
        video.write_videofile(output_path, fps=30, codec='libx264', audio_codec='aac')

        print(f"[✓] Video created at: {output_path}")

    except Exception as e:
        print(f"[ERROR] {e}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python create_video.py <folder_path>")
        sys.exit(1)

    folder = sys.argv[1]
    create_video(folder)
