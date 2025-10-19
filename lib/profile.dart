import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profile_demo_app_with_flutter/mock/mock_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFef5F3),
        appBar: AppBar(
          title: const Text("Profile Information"),
          backgroundColor: Colors.white,
        ),
        body: LayoutBuilder(
          builder: (_, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(16),
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12,
                        children: [
                          _profileImage(),
                          Text(
                            userInfo.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),

                          Text(
                            userInfo.bio,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          _personalInformationContainer(context),
                          //
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _editProfileButton(context),
          ),
        ),
      ),
    );
  }

  // region Profile Image
  Widget _profileImage() {
    return Container(
      width: 100,
      height: 100,
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: ClipOval(
        child: Image.network(
          userInfo.profileImageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Image.asset(
              "assets/images/profilePlaceHolder.png",
              width: 100,
              height: 100,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/images/profilePlaceHolder.png",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
  // endregion Wcdlkl

  // region Personal Information Container
  Widget _personalInformationContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          _userInfoRow(context, "Email", userInfo.email),
          _userInfoRow(context, "Gender", userInfo.gender),
          _userInfoRow(context,"Birth Date",userInfo.formattedBirthDate()),
          _userInfoRow(context, "Nationality", userInfo.nationality),
          _userInfoRow(context, "Phone Number", userInfo.phoneNumber),
          _userInfoRow(context, "Address", userInfo.address),
        ],
      ),
    );
  }
  // endregion

  // region User Info Row
  Widget _userInfoRow(BuildContext context, String title, String subTitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width:
            MediaQuery.of(context).size.width *
                0.4, // adjust this width based on your text length
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),

          // Value
          Expanded(
            child: Text(
              subTitle,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Edit Profile Button
  Widget _editProfileButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text("Edit Profile", style: TextStyle(color: Colors.white)),
      ),
    );
  }
// endregion
}