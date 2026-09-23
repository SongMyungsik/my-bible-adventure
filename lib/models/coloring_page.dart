/// A coloring page: a line-art image whose enclosed white areas get
/// flood-filled with color, tap by tap (like a paint-bucket tool), rather
/// than a set of predefined vector regions.
class ColoringPage {
  const ColoringPage({required this.imageAssetPath});

  final String imageAssetPath;
}
