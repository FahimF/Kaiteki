import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/model/auth/account_compound.dart';
import 'package:kaiteki/ui/shared/dialogs/account_removal_dialog.dart';
import 'package:kaiteki/ui/shared/dialogs/dynamic_dialog_container.dart';
import 'package:kaiteki/ui/shared/posts/avatar_widget.dart';

class AccountListDialog extends ConsumerWidget {
  const AccountListDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicDialogContainer(
      builder: (context, fullscreen) {
        final manager = ref.watch(accountProvider);
        final l10n = context.getL10n();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(l10n.manageAccountsTitle),
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
            ),
            Column(
              children: [
                for (final compound in manager.accounts)
                  AccountListTile(
                    compound: compound,
                    selected: manager.currentAccount == compound,
                  ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).disabledColor,
                    foregroundColor: Colors.white,
                    radius: 22,
                    child: const Icon(Icons.add_rounded),
                  ),
                  title: Text(l10n.addAccountButtonLabel),
                  onTap: () => onTapAdd(context),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        );
      },
    );
  }

  void onTapAdd(BuildContext context) => context.push("/login");
}

class AccountListTile extends ConsumerWidget {
  final AccountCompound compound;
  final bool selected;

  const AccountListTile({
    Key? key,
    required this.compound,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      selected: selected,
      leading: AvatarWidget(
        compound.account,
        size: 44,
      ),
      title: Text(compound.accountSecret.username),
      subtitle: Text(compound.instance),
      onTap: () => _onSelect(ref),
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => _onRemove(context, ref),
        splashRadius: 24,
      ),
    );
  }

  Future<void> _onSelect(WidgetRef ref) async {
    await ref.read(accountProvider).changeAccount(compound);
  }

  Future<void> _onRemove(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AccountRemovalDialog(),
    );

    if (result == true) {
      ref.read(accountProvider).remove(compound);
    }
  }
}
