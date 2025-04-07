import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/translation_service.dart';
import '../../../utils/helpers/twl.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('account'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(context),
            SizedBox(height: 4.h),

            // Settings section
            _buildSettingsSection(context),
            SizedBox(height: 4.h),

            // App section
            _buildAppSection(context),
            SizedBox(height: 4.h),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: Icon(Icons.logout, size: 5.w),
                label: Text(
                  'logout'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 2.h,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100.h,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 15.w,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 15.w,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'john.doe@example.com',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 2.h),
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit, size: 4.w),
              label: Text(
                'editProfile'.tr,
                style: TextStyle(fontSize: 12.sp),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'settings'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.dark_mode,
                title: 'darkMode'.tr,
                trailing: Switch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.language,
                title: 'changeLanguage'.tr,
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 4.w,
                  color: Colors.grey,
                ),
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.notifications,
                title: 'Notifications',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Theme.of(context).primaryColor,
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.info,
                title: 'About Us',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 4.w,
                  color: Colors.grey,
                ),
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 4.w,
                  color: Colors.grey,
                ),
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.contact_support,
                title: 'Contact Us',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 4.w,
                  color: Colors.grey,
                ),
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.star,
                title: 'Rate App',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 4.w,
                  color: Colors.grey,
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 2.h,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 6.w,
              color: Colors.grey,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 15.w,
      endIndent: 0,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('changeLanguage'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageItem(
              context: context,
              language: 'English',
              code: TranslationService.ENGLISH,
            ),
            _buildLanguageItem(
              context: context,
              language: 'Español',
              code: TranslationService.SPANISH,
            ),
            _buildLanguageItem(
              context: context,
              language: 'Français',
              code: TranslationService.FRENCH,
            ),
            _buildLanguageItem(
              context: context,
              language: 'العربية',
              code: TranslationService.ARABIC,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String language,
    required String code,
  }) {
    return ListTile(
      title: Text(language),
      onTap: () {
        TranslationService.changeLocale(code);
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('logout'.tr),
        content: Text('logoutConfirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Perform logout action
              Twl.showSuccessSnackbar('Logged out successfully');
            },
            child: Text(
              'logout'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
