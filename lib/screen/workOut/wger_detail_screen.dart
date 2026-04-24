import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'exercise_video_player.dart';

class WgerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const WgerDetailScreen({super.key, required this.exercise});

  @override
  State<WgerDetailScreen> createState() => _WgerDetailScreenState();
}

class _WgerDetailScreenState extends State<WgerDetailScreen> {
  int _currentImageIndex = 0;
  int _currentVideoIndex = 0;
  bool _showVideos = false;

  // Expandable sections
  bool _showLicenseInfo = false;
  bool _showTechnicalDetails = false;

  @override
  Widget build(BuildContext context) {
    final List<String> videoUrls = List<String>.from(widget.exercise['videoUrls'] ?? []);
    final List<String> imageUrls = List<String>.from(widget.exercise['imageUrls'] ?? []);
    final List muscles = widget.exercise['muscles'] ?? [];
    final List musclesSecondary = widget.exercise['muscles_secondary'] ?? [];
    final List equipment = widget.exercise['equipment'] ?? [];
    final bool hasVideo = videoUrls.isNotEmpty;
    final bool hasImage = imageUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.exercise['name'],
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
              Get.snackbar(
                "Share",
                "Exercise ID: ${widget.exercise['id']}",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          // Favorite button
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Get.snackbar(
                "Favorites",
                "Added to favorites!",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle buttons
              if (hasVideo && hasImage)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMediaToggleButton(
                        "Images (${imageUrls.length})",
                        !_showVideos,
                            () => setState(() => _showVideos = false),
                      ),
                      const SizedBox(width: 10),
                      _buildMediaToggleButton(
                        "Videos (${videoUrls.length})",
                        _showVideos,
                            () => setState(() => _showVideos = true),
                      ),
                    ],
                  ),
                ),
          
              // Media section
              Container(
                color: Colors.black,
                child: Column(
                  children: [
                    // VIDEO CAROUSEL
                    if (hasVideo && (_showVideos || !hasImage))
                      Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 250,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              enableInfiniteScroll: videoUrls.length > 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentVideoIndex = index;
                                });
                              },
                            ),
                            items: videoUrls.map((url) {
                              return Builder(
                                builder: (BuildContext context) {
                                  if (videoUrls.indexOf(url) == _currentVideoIndex) {
                                    return ExerciseVideoPlayer(videoUrl: url);
                                  } else {
                                    return Container(
                                      color: Colors.black,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          if (videoUrls.length > 1)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Video ${_currentVideoIndex + 1}/${videoUrls.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    // IMAGE CAROUSEL
                    else if (hasImage && !_showVideos)
                      Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 250,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              enableInfiniteScroll: imageUrls.length > 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                            ),
                            items: imageUrls.map((url) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      color: Colors.black,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                      ),
                                    ),
                                    memCacheHeight: 500,
                                    maxHeightDiskCache: 800,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          if (imageUrls.length > 1)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Image ${_currentImageIndex + 1}/${imageUrls.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Name Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildBadge(
                                widget.exercise['category'].toString().toUpperCase(),
                                Colors.blue,
                                Icons.category,
                              ),
                              _buildBadge(
                                "ID: ${widget.exercise['id']}",
                                Colors.grey,
                                Icons.tag,
                              ),
                              if (widget.exercise['variations'] != null)
                                _buildBadge(
                                  "${widget.exercise['variations']} Variations",
                                  Colors.purple,
                                  Icons.compare_arrows,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
          
                          // Exercise Name
                          Text(
                            widget.exercise['name'],
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
          
                          // UUID (smaller)
                          if (widget.exercise['uuid'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              "UUID: ${widget.exercise['uuid']}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
          
                    // 💪 Primary Muscles
                    if (muscles.isNotEmpty) ...[
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Primary Muscles", Icons.fitness_center, Colors.red),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: muscles.map((muscle) {
                                return _buildMuscleChip(
                                  muscle['name_en'] ?? muscle['name'] ?? 'Unknown',
                                  Colors.red,
                                  isPrimary: true,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
          
                    // 💪 Secondary Muscles
                    if (musclesSecondary.isNotEmpty) ...[
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Secondary Muscles", Icons.accessibility_new, Colors.orange),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: musclesSecondary.map((muscle) {
                                return _buildMuscleChip(
                                  muscle['name_en'] ?? muscle['name'] ?? 'Unknown',
                                  Colors.orange,
                                  isPrimary: false,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
          
                    // 🏋️ Equipment
                    if (equipment.isNotEmpty) ...[
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Equipment Needed", Icons.build, Colors.green),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: equipment.map((eq) {
                                return _buildEquipmentChip(eq['name'] ?? 'Unknown');
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
          
                    // 📝 Instructions
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Instructions", Icons.list_alt, Colors.blue),
                          const SizedBox(height: 12),
                          Text(
                            widget.exercise['description'],
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: widget.exercise['description'] ==
                                  "No description available."
                                  ? Colors.grey
                                  : Colors.black87,
                              fontStyle: widget.exercise['description'] ==
                                  "No description available."
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
          
                    // 📊 Statistics Card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Statistics", Icons.bar_chart, Colors.indigo),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatBox(
                                  "Videos",
                                  videoUrls.length.toString(),
                                  Icons.video_library,
                                  Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatBox(
                                  "Images",
                                  imageUrls.length.toString(),
                                  Icons.photo_library,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatBox(
                                  "Muscles",
                                  (muscles.length + musclesSecondary.length).toString(),
                                  Icons.fitness_center,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatBox(
                                  "Equipment",
                                  equipment.length.toString(),
                                  Icons.build,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
          
                    // 📅 Date Information
                    if (widget.exercise['created'] != null || widget.exercise['last_update'] != null)
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Timeline", Icons.history, Colors.teal),
                            const SizedBox(height: 12),
                            if (widget.exercise['created'] != null)
                              _buildTimelineItem(
                                "Created",
                                _formatDate(widget.exercise['created']),
                                Icons.add_circle_outline,
                              ),
                            if (widget.exercise['last_update'] != null) ...[
                              const SizedBox(height: 8),
                              _buildTimelineItem(
                                "Last Updated",
                                _formatDate(widget.exercise['last_update']),
                                Icons.update,
                              ),
                            ],
                            if (widget.exercise['last_update_global'] != null) ...[
                              const SizedBox(height: 8),
                              _buildTimelineItem(
                                "Global Update",
                                _formatDate(widget.exercise['last_update_global']),
                                Icons.public,
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
          
                    // 👥 Authors & Contributors (Expandable)
                    if (widget.exercise['author_history'] != null ||
                        widget.exercise['total_authors_history'] != null)
                      _buildExpandableCard(
                        title: "Authors & Contributors",
                        icon: Icons.people,
                        color: Colors.deepPurple,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.exercise['license_author'] != null) ...[
                              Text(
                                "License Author:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.exercise['license_author'],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (widget.exercise['author_history'] != null) ...[
                              Text(
                                "Exercise Authors:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: (widget.exercise['author_history'] as List)
                                    .map((author) => _buildAuthorChip(author.toString()))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (widget.exercise['total_authors_history'] != null) ...[
                              Text(
                                "All Contributors (${(widget.exercise['total_authors_history'] as List).length}):",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: (widget.exercise['total_authors_history'] as List)
                                    .map((author) => _buildContributorChip(author.toString()))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
          
                    // 📜 License Information (Expandable)
                    if (widget.exercise['license'] != null)
                      _buildExpandableCard(
                        title: "License Information",
                        icon: Icons.copyright,
                        color: Colors.brown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLicenseRow(
                              "License Type",
                              widget.exercise['license']['short_name'] ?? 'Unknown',
                            ),
                            const Divider(height: 20),
                            _buildLicenseRow(
                              "Full Name",
                              widget.exercise['license']['full_name'] ?? 'Unknown',
                            ),
                            if (widget.exercise['license']['url'] != null) ...[
                              const Divider(height: 20),
                              InkWell(
                                onTap: () {
                                  // Open URL
                                  Get.snackbar(
                                    "License URL",
                                    widget.exercise['license']['url'],
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.link, size: 18, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.exercise['license']['url'],
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          decoration: TextDecoration.underline,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
          
                    // 🔧 Technical Details (Expandable)
                    _buildExpandableCard(
                      title: "Technical Details",
                      icon: Icons.settings,
                      color: Colors.blueGrey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTechnicalRow("Exercise ID", widget.exercise['id'].toString()),
                          const Divider(height: 16),
                          if (widget.exercise['uuid'] != null) ...[
                            _buildTechnicalRow("UUID", widget.exercise['uuid']),
                            const Divider(height: 16),
                          ],
                          _buildTechnicalRow("Category ID", widget.exercise['category'].toString()),
                          const Divider(height: 16),
                          _buildTechnicalRow("Total Videos", videoUrls.length.toString()),
                          const Divider(height: 16),
                          _buildTechnicalRow("Total Images", imageUrls.length.toString()),
                          const Divider(height: 16),
                          _buildTechnicalRow("Description Length", widget.exercise['description'].length.toString()),
                          if (widget.exercise['variations'] != null) ...[
                            const Divider(height: 16),
                            _buildTechnicalRow("Variations", widget.exercise['variations'].toString()),
                          ],
                        ],
                      ),
                    ),
          
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(icon, size: 24, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: child,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleChip(String name, MaterialColor color, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isPrimary ? 0.15 : 0.1),
            color.withOpacity(isPrimary ? 0.25 : 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isPrimary ? 0.5 : 0.3),
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrimary ? Icons.stars : Icons.star_border,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: color[800],
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 14, color: Colors.green[700]),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.teal[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorChip(String author) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 14, color: Colors.deepPurple[700]),
          const SizedBox(width: 4),
          Text(
            author,
            style: TextStyle(
              fontSize: 12,
              color: Colors.deepPurple[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorChip(String contributor) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey[300]!),
    ),
      child: Text(
        contributor,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  Widget _buildLicenseRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildTechnicalRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildMediaToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}