# RGB Visualization

MATLAB scripts for RGB optical visualization and G/B-based temperature mapping.

## Main files

- `main.m`: batch processing entry point for image sequences.
- `temp.m`: ROI extraction, G/B temperature inversion, heatmap rendering, and output saving.
- `mask.m`: image masking before temperature calculation.
- `rgb.m`: RGB ratio calibration/inspection script.
- `video.m`: utility for assembling processed frames into a video.
- `natsort.m`, `natsortfiles.m`: natural filename sorting helpers.
- `G_B.txt`, `G_B_exp.txt`: G/B reference and experimental calibration data.

Large raw images, generated heatmaps, `.mat` output files, Office documents, and debug images are intentionally excluded from this repository.
