import 'package:flutter/material.dart';

import '../Components/app_number_badge.dart';
import '../SecureStorage/SecureStorageService.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: const [
          // ProfileHeader(),
          // ProfileTabs(),
          Expanded(child: ProfileTabViews()),
        ],
      ),
    );
  }
}

// class ProfileHeader extends StatelessWidget {
//   const ProfileHeader({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       color: AppColors.primaryBlue,
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
//       child: Row(
//         children: [
//           Stack(
//             children: [
//               const CircleAvatar(
//                 radius: 22,
//                 backgroundColor: Color(0xFFBEE47A),
//                 child: Text(
//                   'PQ',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: const EdgeInsets.all(2),
//                   child: const Icon(
//                     Icons.edit,
//                     size: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 10),
//           const Expanded(
//             child: Text(
//               'pallavi',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const Icon(Icons.notifications_none, color: Colors.white),
//         ],
//       ),
//     );
//   }
// }

// class ProfileTabs extends StatelessWidget {
//   const ProfileTabs({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: const TabBar(
//         isScrollable: true,
//         labelColor: AppColors.primaryBlue,
//         unselectedLabelColor: Colors.black54,
//         indicatorColor: AppColors.primaryBlue,
//         tabs: [
//           Tab(text: 'INFO'),
//           Tab(text: 'COURSES'),
//           Tab(text: 'PERFORMANCE'),
//           Tab(text: 'PAYMENTS'),
//         ],
//       ),
//     );
//   }
// }

class ProfileTabViews extends StatelessWidget {
  const ProfileTabViews({super.key});
  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        InfoTab(),
        // Center(child: Text('COURSES')),
        // Center(child: Text('PERFORMANCE')),
        // Center(child: Text('PAYMENTS')),
      ],
    );
  }
}

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: const [
        SectionBasicInformation(),
        SectionTile(number: 2, title: 'Personal Details'),
        SectionTile(number: 3, title: 'Address'),
        SectionTile(number: 4, title: 'Educational Details'),
      ],
    );
  }
}

class SectionBasicInformation extends StatefulWidget {
  const SectionBasicInformation({super.key});

  @override
  State<SectionBasicInformation> createState() =>
      _SectionBasicInformationState();
}

class _SectionBasicInformationState extends State<SectionBasicInformation> {
  String _name = '';
  String _phone = '';
  String _orgCode = "";

  @override
  void initState() {
    super.initState();
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    if (!mounted) return; // safety
    setState(() {
      _name = (user?['name'] ?? '').toString();
      _phone = (user?['phone'] ?? '').toString();
      _orgCode = (user?['OrgCode']).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      number: 1,
      title: 'Basic Information',
      initiallyExpanded: true,
      // trailing: TextButton(onPressed: () {}, child: const Text('EDIT')),
      children: [
        // dynamic (not const)
        InfoRow(
          icon: Icons.person_outline,
          label: 'Name',
          value: _name.isEmpty ? '—' : _name,
        ),
        InfoRow(
          icon: Icons.tag,
          label: 'Mobile Number',
          value: _phone.isEmpty ? '—' : _phone,
        ),

        // static rows can stay const
        InfoRow(
          icon: Icons.mail_outline,
          label: 'Email',
          value: _orgCode.isEmpty ? '—' : _orgCode,
        ),
        const InfoRow(
          icon: Icons.info_outline,
          label: 'About',
          value: '—  —  —  —  —  —  —  —',
        ),
        const InfoRow(
          icon: Icons.confirmation_number_outlined,
          label: 'Roll Number',
          value: '—  —  —  —  —  —  —  —',
        ),
        const InfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Date of Joining',
          value: '—  —  —  —  —  —  —  —',
        ),
      ],
    );
  }
}

class SectionTile extends StatelessWidget {
  const SectionTile({super.key, required this.number, required this.title});
  final int number;
  final String title;
  @override
  Widget build(BuildContext context) {
    return SectionContainer(number: number, title: title, children: const []);
  }
}

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.number,
    required this.title,
    this.initiallyExpanded = false,
    this.trailing,
    required this.children,
  });
  final int number;
  final String title;
  final bool initiallyExpanded;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: AppNumberBadge(number: number),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) trailing!,
              const Icon(Icons.expand_more),
            ],
          ),
          children: children,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
