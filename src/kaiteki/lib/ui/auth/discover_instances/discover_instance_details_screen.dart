import 'package:flutter/material.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/instance_prober.dart';
import 'package:kaiteki/fediverse/instances.dart';
import 'package:kaiteki/ui/auth/discover_instances/adapter_features_expansion_tile.dart';
import 'package:kaiteki/ui/auth/discover_instances/discover_instance_screen_result.dart';
import 'package:kaiteki/ui/auth/discover_instances/fediverse_convenant_chip.dart';
import 'package:kaiteki/ui/auth/discover_instances/mastodon_convenant_chip.dart';
import 'package:kaiteki/ui/auth/discover_instances/rule_list_tile.dart';
import 'package:kaiteki/utils/extensions.dart';
import 'package:kaiteki/utils/extensions/m3.dart';
import 'package:mdi/mdi.dart';

class DiscoverInstanceDetailsScreen extends ConsumerWidget {
  final InstanceData data;

  const DiscoverInstanceDetailsScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.getL10n();
    const chipPadding = EdgeInsets.all(8.0);
    final theme = Theme.of(context);

    var i = 1;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300.0,
              pinned: true,
              floating: true,
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  data.name,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                collapseMode: CollapseMode.pin,
                background: ColoredBox(
                  color: theme.colorScheme.background,
                  child: ShaderMask(
                    blendMode: BlendMode.dstATop,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.red.withOpacity(.50),
                          Colors.transparent,
                        ],
                      ).createShader(bounds);
                    },
                    child: FutureBuilder<String?>(
                      future: fetchInstanceBackground(),
                      builder: (context, snapshot) {
                        final url = snapshot.data;
                        if (url == null) {
                          return const ColoredBox(color: Colors.grey);
                        } else {
                          return Image.network(url, fit: BoxFit.cover);
                        }
                      },
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (data.shortDescription != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 32.0,
                  ),
                  child: Text(data.shortDescription!),
                ),
              if (data.rules != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      l10n.rules,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (data.usesCovenant)
                              const Padding(
                                padding: chipPadding,
                                child: FediverseCovenantChip(),
                              ),
                            if (data.usesMastodonCovenant)
                              const Padding(
                                padding: chipPadding,
                                child: MastodonCovenantChip(),
                              ),
                          ],
                        ),
                      ),
                      for (var rule in data.rules!)
                        RuleListTile(number: i++, rule: rule),
                      if (data.rulesUrl != null)
                        ListTile(
                          title: Text(l10n.rulesLearnMore),
                          trailing: const Icon(Mdi.arrowRight),
                          onTap: () async {
                            await context.launchUrl(data.rulesUrl!);
                          },
                        ),
                    ],
                  ),
                ),
              AdapterFeaturesExpansionTile(data.type),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          DiscoverInstanceScreenResult(data.name, false),
                        );
                      },
                      style: Theme.of(context).filledButtonStyle.copyWith(
                            visualDensity: VisualDensity.comfortable,
                          ),
                      child: Text(l10n.loginButtonLabel),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> fetchInstanceBackground() async {
    final result = await probeInstance(data.name);

    if (result.successful) {
      return result.instance!.backgroundUrl;
    }

    return null;
  }
}