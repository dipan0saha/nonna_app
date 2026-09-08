import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/photo.dart';
import 'package:nonna_app/core/utils/gallery_image_url_resolver.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/features/gallery/presentation/widgets/squish_photo_widget.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/gallery/presentation/providers/photo_detail_provider.dart';
import 'package:nonna_app/features/gallery/presentation/providers/photo_comments_provider.dart';
import 'package:nonna_app/core/themes/colors.dart';
import 'package:nonna_app/core/models/user.dart';

import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  const PhotoDetailScreen({
    super.key,
    this.photo,
    this.photoId,
  }) : assert(
          photo != null || photoId != null,
          'Either photo or photoId must be supplied',
        );

  final Photo? photo;
  final String? photoId;

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  // Resolved photo (populated from widget.photo or fetched by photoId)
  Photo? _resolvedPhoto;
  bool _isLoadingPhoto = false;
  String? _resolveError;

  // Caption editing state
  bool _isEditingCaption = false;
  TextEditingController? _captionController;
  String? _currentCaption;
  Future<String>? _imageUrlFuture;

  // Comment state
  final TextEditingController _commentController = TextEditingController();
  bool _isEditingComment = false;
  String? _editingCommentId;

  @override
  void initState() {
    super.initState();
    if (widget.photo != null) {
      _initializeWithPhoto(widget.photo!);
    } else {
      _isLoadingPhoto = true;
      _fetchPhoto();
    }
  }

  void _initializeWithPhoto(Photo photo) {
    _resolvedPhoto = photo;
    _currentCaption = photo.caption;
    _captionController = TextEditingController(text: _currentCaption);
    _imageUrlFuture = _resolveDisplayUrl(photo.storagePath);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = ref.read(authProvider).user?.id;
      ref.read(photoDetailProvider.notifier).initialize(
            photo: photo,
            userId: userId,
          );
      ref.read(photoCommentsProvider.notifier).loadComments(photo.id);
    });
  }

  Future<void> _fetchPhoto() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final response = await databaseService
          .select(SupabaseTables.photos)
          .eq(SupabaseTables.id, widget.photoId!)
          .single();
      if (!mounted) return;
      final photo = Photo.fromJson(response);
      _initializeWithPhoto(photo);
      setState(() => _isLoadingPhoto = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resolveError = e.toString();
        _isLoadingPhoto = false;
      });
    }
  }

  @override
  void dispose() {
    _captionController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool _isRasterAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lower = url.toLowerCase();
    return !(lower.endsWith('.svg') ||
        lower.contains('.svg?') ||
        lower.endsWith('/svg') ||
        lower.contains('/svg?'));
  }

  Future<void> _showSquishUsers() async {
    final squishCount = ref.read(photoDetailProvider).squishCount;
    try {
      final users = await ref
          .read(photoDetailProvider.notifier)
          .fetchSquishUsers(photoId: _resolvedPhoto!.id);
      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          final title =
              '$squishCount ${squishCount == 1 ? 'squish' : 'squishes'}';
          return SafeArea(
            child: SizedBox(
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Divider(height: 16),
                  if (users.isEmpty)
                    const Expanded(
                      child: Center(child: Text('No squishes yet')),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final User user = users[index];
                          final hasRasterAvatar =
                              _isRasterAvatarUrl(user.avatarUrl);
                          final initial = user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: hasRasterAvatar
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: hasRasterAvatar ? null : Text(initial),
                            ),
                            title: Text(user.displayName),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load squishes. Please try again.')),
      );
    }
  }

  Future<void> _toggleSquish() async {
    final userId = ref.read(authProvider).user?.id;
    final success = await ref.read(photoDetailProvider.notifier).toggleSquish(
          photo: _resolvedPhoto!,
          userId: userId,
        );
    if (!success) {
      final error = ref.read(photoDetailProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        ref.read(photoDetailProvider.notifier).clearError();
      }
    }
  }

  Future<void> _updateCaption() async {
    final newCaption = _captionController!.text.trim();
    if (newCaption == _currentCaption) {
      setState(() => _isEditingCaption = false);
      return;
    }

    final updated = await ref.read(photoDetailProvider.notifier).updateCaption(
          photo: _resolvedPhoto!,
          caption: newCaption,
        );
    if (!updated) {
      final error = ref.read(photoDetailProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        ref.read(photoDetailProvider.notifier).clearError();
      }
      return;
    }

    if (mounted) {
      setState(() {
        _currentCaption = newCaption;
        _isEditingCaption = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).gallery_captionUpdatedSuccess)),
      );
    }
  }

  Future<String> _resolveDisplayUrl(String pathOrUrl) async {
    final storageService = ref.read(storageServiceProvider);
    return GalleryImageUrlResolver.resolve(
      storageService: storageService,
      pathOrUrl: pathOrUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPhoto) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_resolveError != null) {
      return Scaffold(
          body: Center(child: Text('Failed to load photo: $_resolveError')));
    }
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(photoDetailProvider);
    final commentsState =
        ref.watch(photoCommentsProvider)[_resolvedPhoto!.id] ??
            const PhotoCommentsState();
    final commentCount = commentsState.comments.isNotEmpty
        ? commentsState.comments.length
        : _resolvedPhoto!.commentCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gallery_photoDetailTitle),
        actions: [
          if (detailState.isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Photo'),
                    content: const Text(
                        'Are you sure you want to delete this photo?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.common_cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.common_delete,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final success = await ref
                      .read(photoDetailProvider.notifier)
                      .deletePhoto(photo: _resolvedPhoto!);
                  if (success && mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-screen interactive image
            Container(
              key: const Key('photo_detail_image'),
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 300,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              color: Colors.black,
              child: FutureBuilder<String>(
                future: _imageUrlFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white54, size: 50),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.gallery_captionLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (detailState.isOwner && !_isEditingCaption)
                        IconButton(
                          key: const Key('edit_caption_button'),
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () =>
                              setState(() => _isEditingCaption = true),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  AppSpacing.verticalGapXS,
                  if (_isEditingCaption) ...[
                    TextField(
                      key: const Key('caption_edit_field'),
                      controller: _captionController!,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.gallery_captionHint,
                        border: const OutlineInputBorder(),
                        suffixIcon: detailState.isSavingCaption
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                      ),
                      enabled: !detailState.isSavingCaption,
                    ),
                    AppSpacing.verticalGapS,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: detailState.isSavingCaption
                              ? null
                              : () {
                                  _captionController!.text =
                                      _currentCaption ?? '';
                                  setState(() => _isEditingCaption = false);
                                },
                          child: Text(l10n.common_cancel),
                        ),
                        AppSpacing.horizontalGapS,
                        ElevatedButton(
                          onPressed: detailState.isSavingCaption
                              ? null
                              : _updateCaption,
                          child: Text(l10n.common_save),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      _currentCaption ?? l10n.gallery_noCaption,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  AppSpacing.verticalGapM,
                  if (_resolvedPhoto!.tags.isNotEmpty) ...[
                    Text(
                      l10n.gallery_tagsLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    AppSpacing.verticalGapXS,
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: _resolvedPhoto!.tags
                          .map(
                            (tag) => Chip(
                              key: Key('photo_tag_$tag'),
                              label: Text(tag),
                            ),
                          )
                          .toList(),
                    ),
                    AppSpacing.verticalGapM,
                  ],
                  // Uploaded date
                  Text(
                    l10n.gallery_uploadedDate(
                      DateFormat('MMM d, yyyy')
                          .format(_resolvedPhoto!.createdAt),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppSpacing.verticalGapL,
                  // Squish and Comment section
                  Row(
                    children: [
                      SquishPhotoWidget(
                        squishCount: detailState.squishCount,
                        isSquished: detailState.isSquished,
                        onSquish: detailState.isLoading ? null : _toggleSquish,
                        onCountTap: detailState.squishCount > 0
                            ? _showSquishUsers
                            : null,
                      ),
                      AppSpacing.horizontalGapM,
                      // Comment count icon
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 24,
                            color: AppColors.secondary,
                          ),
                          AppSpacing.horizontalGapXS,
                          Text(
                            '$commentCount',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (detailState.isLoading) ...[
                        AppSpacing.horizontalGapS,
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      ]
                    ],
                  ),
                  AppSpacing.verticalGapL,

                  // Comments Section
                  _buildCommentsSection(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(AppLocalizations l10n) {
    final commentsState =
        ref.watch(photoCommentsProvider)[_resolvedPhoto!.id] ??
            const PhotoCommentsState();
    final currentUser = ref.watch(authProvider).user;
    final isOwner = ref.watch(photoDetailProvider).isOwner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gallery_commentsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppSpacing.verticalGapS,

        if (commentsState.isLoading && commentsState.comments.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (commentsState.comments.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(l10n.gallery_noCommentsYet),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: commentsState.comments.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final commentWithAuthor = commentsState.comments[index];
              final comment = commentWithAuthor.comment;
              final author = commentWithAuthor.author;
              final isAuthor = currentUser?.id == comment.userId;
              final canDelete = isAuthor || isOwner;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          author.displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat('MMM d, h:mm a')
                                  .format(comment.createdAt),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            if (isAuthor) ...[
                              IconButton(
                                icon: const Icon(Icons.edit, size: 14),
                                onPressed: () {
                                  setState(() {
                                    _isEditingComment = true;
                                    _editingCommentId = comment.id;
                                    _commentController.text = comment.body;
                                  });
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                            if (canDelete) ...[
                              IconButton(
                                icon:
                                    const Icon(Icons.delete_outline, size: 14),
                                onPressed: () => _deleteComment(comment.id),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    Text(comment.body),
                  ],
                ),
              );
            },
          ),

        AppSpacing.verticalGapL,

        // Add Comment Input
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: _isEditingComment
                      ? l10n.gallery_editCommentHint
                      : l10n.gallery_addCommentHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            AppSpacing.horizontalGapS,
            if (_isEditingComment)
              IconButton(
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  setState(() {
                    _isEditingComment = false;
                    _editingCommentId = null;
                    _commentController.clear();
                  });
                },
              ),
            IconButton(
              icon: Icon(
                _isEditingComment ? Icons.check_circle : Icons.send,
                color: AppColors.primary,
              ),
              onPressed: commentsState.isSubmitting ? null : _submitComment,
            ),
          ],
        ),
        if (commentsState.isSubmitting)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
        AppSpacing.verticalGapXL,
      ],
    );
  }

  Future<void> _submitComment() async {
    final l10n = AppLocalizations.of(context);
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.gallery_loginToComment)),
      );
      return;
    }

    final notifier = ref.read(photoCommentsProvider.notifier);

    if (_isEditingComment && _editingCommentId != null) {
      final updated = await notifier.updateComment(
          photoId: _resolvedPhoto!.id,
          commentId: _editingCommentId!,
          body: body);
      if (!updated) return;
    } else {
      final added = await notifier.addComment(
          photoId: _resolvedPhoto!.id, userId: userId, body: body);
      if (!added) return;

      _refreshParentProviders();
    }

    setState(() {
      _isEditingComment = false;
      _editingCommentId = null;
      _commentController.clear();
    });
  }

  Future<void> _deleteComment(String commentId) async {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.gallery_deleteCommentTitle),
        content: Text(l10n.gallery_deleteCommentMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.common_delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await ref
          .read(photoCommentsProvider.notifier)
          .deleteComment(photoId: _resolvedPhoto!.id, commentId: commentId);
      if (!deleted) return;

      _refreshParentProviders();
    }
  }

  void _refreshParentProviders() {
    ref
        .read(photoDetailProvider.notifier)
        .refreshRelatedTilesForComments(_resolvedPhoto!.babyProfileId);
  }
}
