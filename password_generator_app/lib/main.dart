import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(PasswordGeneratorApp());
}

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier(ThemeMode value) : super(value);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeNotifier = ThemeNotifier(ThemeMode.system);

class PasswordGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Cipher Generator',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          home: PasswordGeneratorHomePage(),
        );
      },
    );
  }
}

class PasswordGeneratorHomePage extends StatefulWidget {
  @override
  _PasswordGeneratorHomePageState createState() => _PasswordGeneratorHomePageState();
}

class _PasswordGeneratorHomePageState extends State<PasswordGeneratorHomePage> {
  double _passwordLength = 12.0;
  bool _useLowercase = true;
  bool _useUppercase = true;
  bool _useDigits = true;
  bool _useSpecial = true;
  String _generatedPassword = '';

  void _generatePassword() {
    final random = Random.secure();
    final List<String> charSets = [];
    if (_useLowercase) charSets.add('abcdefghijklmnopqrstuvwxyz');
    if (_useUppercase) charSets.add('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    if (_useDigits) charSets.add('0123456789');
    if (_useSpecial) charSets.add('!@#\$%^&*()_+-=[]{}|;:,.<>?');

    if (charSets.isEmpty) {
      setState(() {
        _generatedPassword = 'Select at least one character type.';
      });
      return;
    }

    List<String> password = [];
    // Ensure at least one character from each selected set
    charSets.forEach((set) {
      password.add(set[random.nextInt(set.length)]);
    });

    // Fill the rest of the password
    final allChars = charSets.join();
    for (int i = password.length; i < _passwordLength; i++) {
      password.add(allChars[random.nextInt(allChars.length)]);
    }

    // Shuffle the password
    password.shuffle(random);

    setState(() {
      _generatedPassword = password.join();
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color.fromRGBO(255, 255, 255, 0.1)
                    : const Color.fromRGBO(0, 0, 0, 0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 35,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Password Generator',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Will be adjusted by theme later
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password Display
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color.fromRGBO(0, 0, 0, 0.2)
                          : const Color.fromRGBO(255, 255, 255, 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                      children: [
                        Expanded(
                          child: SelectableText(
                            _generatedPassword,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Will be adjusted by theme later
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white), // Will be adjusted by theme later
                          onPressed: _copyToClipboard,
                          tooltip: 'Copy Password',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Length Slider
                  Column(
                    children: [
                      Text(
                        'Password Length: ${_passwordLength.round()}',
                        style: const TextStyle(fontSize: 16, color: Colors.white), // Will be adjusted by theme later
                      ),
                      Slider(
                        value: _passwordLength,
                        min: 4,
                        max: 32,
                        divisions: 28,
                        label: _passwordLength.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _passwordLength = value;
                          });
                        },
                        activeColor: const Color(0xFFFF6B6B), // Matches HTML button color
                        inactiveColor: Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Character Type Switches
                  _buildOptionRow(
                    context,
                    'Include Lowercase',
                    _useLowercase,
                    (value) => setState(() => _useLowercase = value),
                  ),
                  _buildOptionRow(
                    context,
                    'Include Uppercase',
                    _useUppercase,
                    (value) => setState(() => _useUppercase = value),
                  ),
                  _buildOptionRow(
                    context,
                    'Include Digits',
                    _useDigits,
                    (value) => setState(() => _useDigits = value),
                  ),
                  _buildOptionRow(
                    context,
                    'Include Special Characters',
                    _useSpecial,
                    (value) => setState(() => _useSpecial = value),
                  ),
                  const SizedBox(height: 20),

                  // Generate Button
                  ElevatedButton(
                    onPressed: _generatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B), // Matches HTML button color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Generate Password'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                _buildTopButton(
                  context,
                  themeNotifier.value == ThemeMode.light ? Icons.wb_sunny : Icons.nightlight_round,
                  () {
                    themeNotifier.toggleTheme();
                  },
                ),
                const SizedBox(width: 10),
                _buildTopButton(
                  context,
                  Icons.info_outline,
                  () {
                    _showInfoModal(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(BuildContext context, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(0, 0, 0, 0.1)
            : const Color.fromRGBO(255, 255, 255, 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white), // Will be adjusted by theme later
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF6B6B), // Matches HTML button color
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(255, 255, 255, 0.2)
            : const Color.fromRGBO(0, 0, 0, 0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20), // Will be adjusted by theme later
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showInfoModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromRGBO(255, 255, 255, 0.1)
                  : const Color.fromRGBO(0, 0, 0, 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const Text(
                        'About Cipher Generator',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Modern Password Generator',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Built by Ionut Ciprian Anescu',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          const url = 'https://github.com/ItIsCiprian';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not launch GitHub profile.')),
                            );
                          }
                        },
                        child: const Text(
                          'GitHub Profile: https://github.com/ItIsCiprian',
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Features',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '- Customizable Password Generation: Generate passwords of any length with your choice of character types (lowercase, uppercase, digits, special characters).
'
                        '- Interactive CLI: A user-friendly command-line interface that guides you through the password generation process.
'
                        '- Modern Web UI: A beautiful and responsive web interface with interactive controls and a sleek design.
'
                        '- Secure: Generates strong, random passwords to protect your accounts.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Project Overview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This project contains two implementations of a random password generator:',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const Text(
                        '
1. A Flutter application: A cross-platform app that allows you to generate random passwords with customizable options.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const Text(
                        '
2. A simple web version: A basic HTML and Python-based password generator.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'License: GPL v3',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'GNU General Public License v3.0

'
                        'Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
'
                        'Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.

'
                        'Preamble

'
                        'The GNU General Public License is a free, copyleft license for software and other kinds of works.

'
                        'The licenses for most software and other practical works are designed to take away your freedom to share and change the works. By contrast, the GNU General Public License is intended to guarantee your freedom to share and change all versions of a program--to make sure it remains free software for all its users. We, the Free Software Foundation, are using this License for most of our software; it applies also to any other work released this way by its authors. You can apply it to your programs, too.

'
                        'When we speak of free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for them if you wish), that you receive source code or can get it if you want it, that you can change software or use pieces of it in new free programs, and that you know you can do these things.

'
                        'To protect your rights, we need to prevent others from denying you these rights or asking you to surrender the rights. Therefore, you have certain responsibilities if you distribute copies of the software, or if you modify it: responsibilities to respect the freedom of others.

'
                        'For example, if you distribute copies of such a program, whether gratis or for a fee, you must pass on to the recipients the same freedoms that you received. You must make sure that they, too, receive or can get the source code. And you must show them these terms so they know their rights.

'
                        'Developers that use the GNU GPL protect your rights with two steps: (1) assert copyright on the software, and (2) offer you this License giving you legal permission to copy, distribute and/or modify it.

'
                        'For the developers' and authors' protection, the GPL clearly explains that there is no warranty for this free software. For both users' and authors' sake, the GPL requires that modified versions be marked as changed, so that their problems will not be attributed erroneously to authors of previous versions.

'
                        'Some devices are designed to deny users access to install or run modified versions of the software inside them, although the manufacturer can do so. This is fundamentally incompatible with the aim of protecting users' freedom to change the software. The systematic pattern of such abuse occurs in the area of products for individuals to use, which is precisely where it is most unacceptable. Therefore, we have designed this version of the GPL to prohibit the practice for those products. If such problems arise in other domains, we stand ready to extend this provision to those domains in future versions of the GPL, as needed to protect the freedom of users.

'
                        'Finally, every program is threatened constantly by software patents. States should not allow patents to restrict development and use of software on general-purpose computers, but in those that do, we wish to avoid the special danger that patents applied to a free program could make it effectively proprietary. To prevent this, the GPL ensures that a patent cannot be used to render the program non-free.

'
                        'The precise terms and conditions for copying, distribution and modification follow.

'
                        'TERMS AND CONDITIONS

'
                        '0. Definitions.

'
                        '"This License" refers to version 3 of the GNU General Public License.

'
                        '"The Program" refers to any copyrightable work licensed under this License. Each licensee is addressed as "you". "Licensees" and "recipients" may be individuals or organizations.

'
                        'To "modify" a work means to copy from or adapt all or part of the work in a fashion requiring copyright permission, other than the making of an exact copy. The resulting work is called a "modified version" of the earlier work or a work "based on" the earlier work.

'
                        'A "covered work" means either the unmodified Program or a work based on the Program.

'
                        'To "propagate" a work means to do anything with it that, without permission, would make you directly or secondarily liable for infringement under applicable copyright law, except executing it on a computer or modifying a private copy. Propagation includes copying, redistribution, reverse engineering, decompilation, and public display.

'
                        'A "contributor" is an author of the Program or an entity who has authorized use of the Program under this License.

'
                        '"Your legal rights" means the rights provided by copyright law or patent law, in this or other jurisdictions, that are granted to you to perform, disseminate or run the covered work.

'
                        '"Convey" a work means any kind of propagation that enables other parties to make or receive copies. Mere interaction with a user through a computer network, with no transfer of a copy, is not conveying.

'
                        'An interactive user interface displays "Appropriate Legal Notices" to the extent that it includes a convenient and prominently visible feature that (1) displays an appropriate copyright notice, and (2) tells the user that there is no warranty for the work (provided that the users are not otherwise provided a warranty by virtue of assuming warranty liabilities from third party providers), and (3) tells the users that the work is licensed under this License, and (4) gives operational instructions for viewing a copy of this License. If the interface presents a list of user commands or options, such as a menu, a prominent item in the list would qualify.

'
                        '1. Source Code.

'
                        'The "source code" for a work means the preferred form of the work for making modifications to it. "Object code" means any non-source form of a work.

'
                        'A "Standard Interface" means an interface that either is an official standard defined by a recognized standards body, or, in the case of interfaces specified for a particular programming language, one that is widely used among developers working in that language.

'
                        'The "System Libraries" of an executable work include anything, other than the work as a whole, that (a) is included in the normal form of packaging a Major Component, but which is not part of that Major Component, and (b) serves only to enable use of the work with that Major Component, or to implement a Standard Interface for which an implementation is available to the public in source code form. A "Major Component", in this context, means a major essential component (kernel, window system, and so on) of the specific operating system (if any) on which the executable work runs, or a compiler used to produce the work, or an object code interpreter used to run it.

'
                        'The "Corresponding Source" for a work in object code form means all the source code needed to generate, install, and run the object code and to modify the work, including scripts to control those activities. However, it does not include the work's System Libraries, or general-purpose tools or generally available free programs which are used unmodified in performing those activities but which are not part of the work. For example, Corresponding Source includes interface definition files associated with source files, and the source code for shared libraries and dynamically linked subprograms that the work is specifically designed to require, such as by intimate data communication or control flow between those subprograms and other parts of the work.

'
                        'The Corresponding Source need not include anything that users can regenerate automatically from other parts of the Corresponding Source.

'
                        'The Corresponding Source for a work in source code form is that same work.

'
                        '2. Basic Permissions.

'
                        'All rights granted under this License are granted for the term of copyright on the Program, and are irrevocable provided the stated conditions are met. This License explicitly affirms your unlimited permission to run the unmodified Program. The output from running a covered work is covered by this License only if the output, given its content, constitutes a covered work. This License acknowledges your rights of fair use or other equivalent, as provided by copyright law.

'
                        'You may make, run and propagate covered works that you do not convey, without any condition so long as your license otherwise remains in force. You may convey covered works to others for the sole purpose of having them make modifications exclusively for you, or provide you with facilities for running those works, provided that you comply with the terms of this License in conveying all material for which you do not control copyright. Those thus making or running the covered works for you must do so exclusively on your behalf, under your direction and control, on terms that prohibit them from making any copies of your copyrighted material outside their relationship with you.

'
                        'Conveying under any other circumstances is permitted solely under the conditions stated below. Sublicensing is not allowed; section 10 makes it unnecessary.

'
                        '3. Protecting Users' Legal Rights From Anti-Circumvention Law.

'
                        'No covered work shall be deemed part of an effective technological measure under any applicable law fulfilling obligations under Article 11 of the WIPO copyright treaty adopted on 20 December 1996, or similar laws prohibiting or restricting circumvention of such measures.

'
                        'When you convey a covered work, you waive any legal power to forbid circumvention of technological measures to the extent such circumvention is effected by exercising rights under this License with respect to the covered work, and you disclaim any intention to limit operation or modification of the work to the detriment of the work's users.

'
                        '4. Conveying Verbatim Copies.

'
                        'You may convey verbatim copies of the Program's source code as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice; keep intact all notices stating that this License and any non-permissive terms added in accord with section 7 apply to the code; keep intact all notices of the absence of any warranty; and give all recipients a copy of this License along with the Program.

'
                        'You may charge any price or no price for each copy that you convey, and you may offer support or warranty protection for a fee.

'
                        '5. Conveying Modified Source Versions.

'
                        'You may convey a work based on the Program, or the modifications to produce it from the Program, in the form of source code under the terms of section 4, provided that you also meet all of these conditions:

'
                        'a) The work must carry prominent notices stating that you modified it, and giving a relevant date.

'
                        'b) The work must carry prominent notices stating that it is released under this License and any conditions added under section 7. This requirement modifies the requirement in section 4 to "keep intact all notices".

'
                        'c) You must license the entire work, as a whole, under this License to anyone who comes into possession of a copy. This License will therefore apply, along with any applicable section 7 additional terms, to the whole of the work, and all its parts, regardless of how they are packaged. This License gives no permission to license the work in any other way, but it does not invalidate such permission if you have separately received it.

'
                        'd) If the work has interactive user interfaces, each must display "Appropriate Legal Notices"; however, if the Program has interactive interfaces that do not display Appropriate Legal Notices, your work need not make them do so.

'
                        'A compilation of a covered work with other separate and independent works, which are not by their nature extensions of the covered work, and which are not combined with it such as to form a larger program, in or on a volume of a storage or distribution medium, is called an "aggregate" if the compilation and its resulting copyright are not used to limit the access or legal rights of the compilation's users beyond what the individual works permit. Inclusion of a covered work in an aggregate does not cause this License to apply to the other parts of the aggregate.

'
                        '6. Conveying Non-Source Forms.

'
                        'You may convey a covered work in object code form under the terms of sections 4 and 5, provided that you also convey the Corresponding Source in one of the ways below:

'
                        'a) Convey the object code in, or embodied in, a physical product (including a physical distribution medium), accompanied by the Corresponding Source fixed on a durable physical medium customarily used for software interchange.

'
                        'b) Convey the object code in, or embodied in, a physical product (including a physical distribution medium), accompanied by a written offer, valid for at least three years and valid for as long as you offer spare parts or customer support for that product model, to give anyone who possesses the object code either (1) a copy of the Corresponding Source for all the software in the product that is covered by this License, on a durable physical medium customarily used for software interchange, for a price no more than your reasonable cost of physically performing this conveying of source, or (2) access to copy the Corresponding Source from a network server at no charge.

'
                        'c) Convey individual copies of the object code with a copy of the written offer to provide the Corresponding Source. This alternative is allowed only occasionally and non-commercially, and only if you received the object code with such an offer, in accord with section 6b.

'
                        'd) Convey the object code by offering access from a designated place (gratis or for a charge), and offer equivalent access to the Corresponding Source in the same way through the same place at no further charge. You need not require recipients to copy the Corresponding Source along with the object code. If the place is a network server, the Corresponding Source may be on a different server (operated by you or a third party) that supports equivalent copying facilities, provided you maintain clear directions next to the object code where to find the Corresponding Source. Regardless of what server hosts the Corresponding Source, you remain obligated to ensure that it is available for as long as needed to satisfy these requirements.

'
                        'e) Convey the object code using peer-to-peer transmission, provided you inform other peers where the object code and Corresponding Source of the work are being offered to the general public at no charge under subsection 6d.

'
                        'A separable portion of the object code, whose source code is excluded from the Corresponding Source as a System Library, need not be included in conveying the object code work.

'
                        'A "User Product" is either (1) a "consumer product", which means any tangible personal property which is normally used for personal, family, or household purposes, or (2) anything designed or sold for incorporation into a dwelling. In determining whether a product is a consumer product, doubtful cases shall be resolved in favor of coverage. For a particular product received by a particular user, "normally used" refers to a typical or common use of that class of product, regardless of the status of the particular user or of the way in which the particular user actually uses, or expects or is expected to use, the product. A product is a consumer product if it has substantially new features, or new accessory uses, not previously available, unless the only way to achieve such features and uses is to modify a data file.

'
                        'A "Installation Information" for a User Product means any methods, procedures, authorization keys, or other information required to install and execute modified versions of a covered work in that User Product from a modified version of its Corresponding Source. The information must suffice to ensure that the continued functioning of the modified object code is in no case prevented or interfered with solely because modification has been made.

'
                        'If you convey an object code work under this section in, or with, the ability to install modified versions of the covered work in a User Product, and the User Product is in the possession of the user, you must convey the Installation Information. The requirement to provide Installation Information does not include a requirement to continue to provide support service, warranty, or updates for a work that has been modified or installed by the recipient, or for the User Product in which it has been modified or installed. Access to a network may be denied when the modification itself materially and adversely affects operation of the network or the protocol over which communication takes place.

'
                        'Corresponding Source conveyed, and Installation Information provided, in accord with this section must be in a format that is publicly documented (and with an implementation available to the public in source code form), and must require no special password or key for unpacking, reading or copying.

'
                        '7. Additional Terms.

'
                        '"Additional permissions" are terms that supplement the terms of this License by making exceptions from one or more of its conditions. Additional permissions that are applicable to the entire Program shall be treated as though they were included in this License, to the extent that they are valid under applicable law. If additional permissions apply only to part of the Program, that part may be used separately under those permissions, but the entire Program remains governed by this License without regard to the additional permissions when held as a whole.

'
                        'When you convey a copy of a covered work, you may at your option remove any additional permissions from that copy. (Additional permissions may be written to require their own removal in certain cases when you modify the work.) You may place additional permissions on material, added by you to a covered work, for which you have or can give appropriate copyright permission.

'
                        'Notwithstanding any other provision of this License, for material you add to a covered work, you may (if authorized by the copyright holders of that material) supplement the terms of this License with terms:

'
                        'a) Disclaiming warranty or limiting liability differently from the terms of sections 15 and 16 of this License; or

'
                        'b) Requiring preservation of specified reasonable legal notices or author attributions in that material or in the Appropriate Legal Notices displayed by works containing it; or

'
                        'c) Prohibiting misrepresentation of the origin of that material, or requiring that modified versions of such material be marked in reasonable ways as differing from the original version; or

'
                        'd) Limiting the use for publicity purposes of names or trademarks; or

'
                        'e) Declining to grant rights under trademark law for use of some trade names, trademarks, or service marks; or

'
                        'f) Requiring indemnification of licensors and authors of that material by anyone who conveys the material (or modified versions of it) with contractual assumptions of liability to the recipient, for any liability that these contractual assumptions directly impose on those licensors and authors.

'
                        'All other non-permissive additional terms are considered "further restrictions" within the meaning of section 10. If the Program as you received it, or any part of it, contains a notice stating that it is governed by this License along with a term that is a further restriction, you may remove that term. If a license document contains a further restriction but permits relicensing or conveying under this License, you may use that license document, or a combined version of it, to convey the Program, provided that you remove that further restriction.

'
                        '8. Termination.

'
                        'You may not propagate or modify a covered work except as expressly provided under this License. Any attempt otherwise to propagate or modify it is void, and will automatically terminate your rights under this License (including any patent licenses granted under the first paragraph of section 11).

'
                        'However, if you cease all violation of this License, then your license from a particular copyright holder is reinstated (a) provisionally, unless and until the copyright holder explicitly and finally terminates your license, and (b) permanently, if the copyright holder fails to notify you of the violation by some reasonable means prior to 60 days after the cessation.

'
                        'Moreover, your license from a particular copyright holder is reinstated permanently if the copyright holder notifies you of the violation by some reasonable means, this is the first time you have received notice of violation of this License (for any work) from that copyright holder, and you cure the violation prior to 30 days after your receipt of the notice.

'
                        'Termination of your rights under this section does not terminate the licenses of parties who have received copies or rights from you under this License. If your rights have been terminated and not permanently reinstated, you do not have permission to run, display, perform, propagate, or modify the Program.

'
                        '9. Acceptance Not Required for Having Copies.

'
                        'You are not required to accept this License in order to receive or run a copy of the Program. Ancillary propagation of a covered work without acceptance likewise does not require acceptance. However, nothing other than this License grants you permission to propagate or modify any covered work. These actions infringe copyright if you do not accept this License. Therefore, by modifying or propagating a covered work, you indicate your acceptance of this License to do so.

'
                        '10. Automatic Licensing of Downstream Recipients.

'
                        'Each time you convey a covered work, the recipient automatically receives a license from the original licensors, to run, modify and propagate that work, subject to this License. You are not responsible for enforcing compliance by third parties with this License.

'
                        'An "entity transaction" is a transaction transferring control of an organization, or substantially all assets of one, or subdividing an organization, or merging organizations. If propagation of a covered work results from an entity transaction, each party to that transaction who receives a copy of the work also receives whatever licenses to the work the party's predecessor in interest had or could give under the above paragraph, plus a right to possession of the Corresponding Source of the work from the predecessor in interest, if the predecessor has it or can get it with reasonable efforts.

'
                        'You may not impose any further restrictions on the exercise of the rights granted or affirmed under this License. For example, you may not impose a license fee, royalty, or other charge for exercise of rights granted under this License, and you may not initiate litigation (including a cross-claim or counterclaim in a lawsuit) alleging that any patent claim is infringed by making, using, selling, offering for sale, or importing the Program or any portion of it.

'
                        '11. Patents.

'
                        'A "contributor" is a copyright holder who authorizes use under this License of the Program or a work on which the Program is based.

'
                        'A contributor's "essential patent claims" are all patent claims owned or controlled by the contributor, whether already acquired or hereafter acquired, that would be infringed by some manner of making, using, or selling, offering for sale, or importing the Program in unmodified form. For the purposes of this definition, "control" includes the right to grant sublicenses of patent rights in a manner consistent with the requirements of this License.

'
                        'Each contributor grants you a non-exclusive, worldwide, royalty-free patent license under the contributor's essential patent claims, to make, use, sell, offer for sale, import and otherwise run, modify and propagate the contents of the Program.

'
                        'In the following three paragraphs, a "patent license" is any express agreement or commitment, however denominated, not to enforce a patent (such as an express permission to practice a patent or covenant not to sue for patent infringement). To "grant" such a patent license to a party means to make such an agreement or commitment not to enforce a patent against the party.

'
                        'If you convey a covered work, knowingly relying on a patent license in connection with the Corresponding Source of the work, and the Corresponding Source is not available to anyone to copy free of charge under the terms of section 6, then you must arrange to either:
'
                        '(1) cause the Corresponding Source to be available free of charge under the terms of section 6, or (2) arrange to deprive yourself of the benefit of the patent license for this particular work, or (3) arrange in a manner consistent with the requirements of this License to extend the patent license to recipients of the Corresponding Source. "Knowingly relying" means you have actual knowledge that, but for the patent license, your conveying the covered work in a country, or your recipient's use of the covered work in a country, would infringe one or more identifiable patents in that country that you have reason to believe are valid.

'
                        'If, pursuant to or in connection with a single transaction or arrangement, you convey, or propagate by procuring conveyance of, a covered work, and the procuring party also receives a patent license from some third party that is an organization in the business of distributing software, whose distributed product contains the covered work, then your conveying the covered work includes a patent license from you to the recipients for the Program's essential patent claims in the covered work, to the extent you control them.

'
                        'A patent license is "discriminatory" if it does not include within its scope the activity for which freedom is granted under this License, is not granted on the formation of an entity, or does not permit the exercise of a patent right that would otherwise be infringed by the exercise of a right granted under this License.

'
                        'You may not convey a covered work if you are a party to an arrangement with a third party that is in the business of distributing software, under which you make payment to the third party based on the extent of your conveying the work, and under which the third party grants, to any of the parties who would receive the covered work from you, a discriminatory patent license (a) in connection with copies of the covered work conveyed by you (or copies made from those copies), or (b) primarily for and in connection with specific products or compilations that contain the covered work, unless you entered into that arrangement, or that patent license was granted, prior to 28 March
'
                        '2007.

'
                        'Nothing in this License shall be construed as excluding or limiting any implied license or other defenses to infringement that may otherwise be available to you under applicable patent law.

'
                        '12. No Surrender of Others' Freedom.

'
                        'If conditions are imposed on you (whether by court order, agreement or otherwise) that contradict the conditions of this License, they do not excuse you from the conditions of this License. If you cannot convey a covered work so as to satisfy simultaneously your obligations under this License and any other pertinent obligations, then as a consequence you may not convey it at all. For example, if you agree to terms that obligate you to collect a royalty for onward conveying of the Program, and the only way you could satisfy that term is to forego all conveying of the Program, then you must forego conveying of the Program.

'
                        '13. Use with the GNU Affero General Public License.

'
                        'Notwithstanding any other provision of this License, you have permission to link or combine any covered work with a work licensed under version 3 of the GNU Affero General Public License into a single combined work, and to convey the resulting work. The terms of this License will continue to apply to the part which is the covered work, but the special requirements of the GNU Affero General Public License, section 13, concerning interaction through a network will apply to the combination as such.

'
                        '14. Revised Versions of this License.

'
                        'The Free Software Foundation may publish revised and/or new versions of
'
                        'the GNU General Public License from time to time. Such new versions will
'
                        'be similar in spirit to the present version, but may differ in detail to
'
                        'address new problems or concerns.

'
                        'Each version is given a distinguishing version number. If the Program
'
                        'specifies that a certain numbered version of the GNU General Public
'
                        'License "or any later version" applies to it, you have the option of
'
                        'following the terms and conditions either of that numbered version or
'
                        'of any later version published by the Free Software Foundation. If the
'
                        'Program does not specify a version number of the GNU General Public
'
                        'License, you may choose any version ever published by the Free Software
'
                        'Foundation.

'
                        'If the Program specifies that a proxy can decide which future versions
'
                        'of the GNU General Public License can be used, that proxy's public
'
                        'statement of acceptance of a version permanently authorizes you to choose
'
                        'that version for the Program.

'
                        'Preamble: <https://www.gnu.org/licenses/gpl-3.0.html>
'
                        'How to Apply These Terms to Your New Programs: <https://www.gnu.org/licenses/gpl-3.0.html#howto>
'
                        '''',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

