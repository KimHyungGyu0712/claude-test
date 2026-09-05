// 이 파일은 공지사항을 쓰고, 고치고, 지우는 화면입니다.
// 왼쪽에서 제목과 내용을 입력해 등록하고, 오른쪽 목록에서 최신 공지부터 확인합니다.
// '중요' 표시를 켜면 목록에서 빨간 아이콘으로 눈에 띄게 표시됩니다.

import 'package:flutter/material.dart';

import '../../models/notice.dart';
import '../../services/format_utils.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_header.dart';

/// 공지 작성 화면
class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final _data = MockDataService.instance;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  /// 중요 공지 여부
  bool _important = false;

  /// 수정 중인 공지의 id. null이면 새 글을 쓰는 중입니다.
  String? _editingId;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 입력칸을 비우고 '새 공지 쓰기' 상태로 되돌립니다.
  void _resetForm() {
    setState(() {
      _editingId = null;
      _important = false;
      _titleController.clear();
      _contentController.clear();
    });
  }

  /// 목록에서 '수정'을 누르면 그 내용을 입력칸으로 가져옵니다.
  void _startEdit(Notice notice) {
    setState(() {
      _editingId = notice.id;
      _important = notice.important;
      _titleController.text = notice.title;
      _contentController.text = notice.content;
    });
  }

  /// 등록 또는 수정 저장
  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      _toast('제목과 내용을 모두 입력하세요.');
      return;
    }
    if (_editingId == null) {
      _data.addNotice(title: title, content: content, important: _important);
      _toast('공지를 등록했습니다.');
    } else {
      _data.updateNotice(
        id: _editingId!,
        title: title,
        content: content,
        important: _important,
      );
      _toast('공지를 수정했습니다.');
    }
    _resetForm();
  }

  /// 삭제 (한 번 더 확인)
  Future<void> _delete(Notice notice) async {
    final ok = await showConfirmDialog(
      context,
      title: '공지 삭제',
      message: '"${notice.title}" 공지를 삭제할까요?',
      confirmText: '삭제',
    );
    if (!ok || !mounted) return;
    _data.deleteNotice(notice.id);
    if (_editingId == notice.id) _resetForm();
    _toast('공지를 삭제했습니다.');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _data,
      builder: (context, _) {
        final notices = _data.notices;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '공지 작성',
              subtitle: '등록된 공지 ${notices.length}건 (최신순)',
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 왼쪽: 작성/수정 입력칸 ──────────────
                  SizedBox(
                    width: 380,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _editingId == null ? '새 공지 작성' : '공지 수정',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: '제목',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _contentController,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                labelText: '내용',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              value: _important,
                              onChanged: (v) =>
                                  setState(() => _important = v ?? false),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              title: const Text('중요 공지로 표시'),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: _save,
                                  icon: const Icon(Icons.check),
                                  label: Text(
                                    _editingId == null ? '등록' : '수정 저장',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (_editingId != null)
                                  TextButton(
                                    onPressed: _resetForm,
                                    child: const Text('취소'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // ── 오른쪽: 공지 목록 ──────────────────
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: notices.isEmpty
                          ? const EmptyState(message: '등록된 공지가 없습니다.')
                          : ListView.separated(
                              itemCount: notices.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final n = notices[index];
                                return ListTile(
                                  leading: Icon(
                                    n.important
                                        ? Icons.priority_high
                                        : Icons.campaign_outlined,
                                    color: n.important
                                        ? Colors.red
                                        : theme.colorScheme.outline,
                                  ),
                                  title: Text(n.title),
                                  subtitle: Text(
                                    '${n.content}\n'
                                    '${n.authorName} · ${formatDateTime(n.createdAt)}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: '수정',
                                        onPressed: () => _startEdit(n),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: '삭제',
                                        onPressed: () => _delete(n),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
