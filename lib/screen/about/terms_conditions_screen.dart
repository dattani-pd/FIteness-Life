import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==============================================================================
// TERMS & CONDITIONS SCREEN (Themed)
// ==============================================================================

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME COLORS
    final bool isDark = Get.isDarkMode;
    final Color bg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color bodyColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color dividerColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("TRAINER - TERMS OF USE", "", textColor, bodyColor),

            _buildSection(
                "1. Introduction and Terms and Conditions of use",
                "1.1. The mobile application “Fitness is Life” (“App”) is owned by “Brisley” (“Trainer” or “Trainers”, “we” or “our” or “us”), a certified fitness Trainer from the USA and having its principal place of business at Ashburn Virginia , USA.\n\n"
                    "1.2. App is a product that allows personal trainers, wellness coaches and nutritionists (collectively, the “Trainers”) to provide training and coaching and interact with their clients (the “Clients”). App assists the Trainers in administering their business activities, i.e., to manage Clients, create workout plans, meal plans, recipes, and exercises, track the progress of the Clients, and upload and store documents, videos, and other files supporting Trainers’ business activities. App also allows the Clients to interact with the Trainers through the App and track their progress in the field of fitness, diet, and healthy lifestyle.\n\n"
                    "1.3. Any person using our App (“User” or “you”) shall be presumed to have read the Terms of Use (which includes the Disclaimer and Privacy Policy, separately provided on the App) and has unconditionally accepted the terms and conditions of use and these constitute a binding and enforceable agreement between the User and the Trainer.\n\n"
                    "1.4. The User of the App are governed by the following terms and conditions (“Terms of Use”) including the applicable policies which are incorporated herein by way of reference. By mere use of App, the User shall be under a binding obligation to comply with these terms and conditions including the policies mentioned hereinafter.\n\n"
                    "1.5. For the purpose of these Terms of Use, wherever the context so requires “User” shall mean any natural or legal person who has agreed to these Terms of Use on behalf of herself / himself or any other legal entity.\n\n"
                    "1.6. For purposes of these Terms of Use, the term “Content” includes, without limitation, information, data, text, logos, photographs, videos, audio clips, animations, written posts, articles, comments, software, scripts, graphics, themes and interactive features generated, provided or otherwise made accessible on or through the use of App, including the User Content (as defined hereinafter).\n\n"
                    "1.7. The Terms of Use may be revised or altered by the Trainer at its sole discretion at any time without any prior intimation to the Users. The latest Terms of Use will be posted here. By continuing to use or access App after changes are made, you agree to be bound by the revised/ altered Terms of Use.",
                textColor, bodyColor
            ),

            _buildSection(
                "2. Eligibility",
                "2.1. Any person who is above 18 (eighteen) years of age and competent to contract under applicable laws is eligible to use / download the App. Your use and download of the App shall be treated as your representation that you are competent to contract.\n\n"
                    "2.2. The User represents and warrants that the User will be responsible, for all of the User's use of App (as well as use of User's account by others) and that the Trainer shall not be attributed with any liability for the content posted by you. Further, the Trainer shall not be responsible for any damage or injury caused (physical or otherwise). The Terms of Use shall be void where prohibited by applicable laws, and the use of App shall automatically stand revoked in such cases.",
                textColor, bodyColor
            ),

            _buildSection(
                "3. Account and Registration",
                "3.1. In order to use the App, you must first register and create an account with us (“User Account”). As a first step, you are required to download the App and create an account. Before creating your User Account, you will be requested to read and accept these Terms, the Disclaimer, and review the Privacy Policy. The personal data related to your User Account will be processed in accordance with our Privacy Policy. Your User Account is not transferable, and you are solely responsible for any activities occurring through your User Account.\n\n"
                    "3.2. Any information provided to us during the registration process or otherwise, will be protected in accordance with our Privacy Policy separately provided on the App.\n\n"
                    "3.3. If you use App, you are responsible for maintaining the confidentiality of your password and other details in relation to your User Account and any activity that occurs in or through the User Account. By using App, you agree to immediately notify us about allegedly unauthorized use of your User Account or any other security breach related to your User Account. We will not be liable to any person for any loss or damage which may arise because of any failure by you to protect your password or User Account.\n\n"
                    "3.4. Any Client registering and creating a User Account hereby represents that they are duly authorized to do so. Further, the acceptance of these Terms of Use, they bind any business entity associated with them to these Terms of Use. At any time, you may delete your Account through the functionality of your User Account. Upon deactivation of the User Account, these Terms shall terminate.\n\n"
                    "3.5. If anyone other than yourself accesses your User Account, they may perform any actions available to you, make changes to your User Account, and accept any legal terms available therein, make various representations and warranties etc. Any such action/ activity will be deemed to have occurred on your behalf and in your name. The App has firewalls in place to protect the User Content but it does not guarantee any unauthorized access by any third party of your User Content. If you know or suspect that someone else knows your password or suspect any unauthorized use of your password you should notify us by contacting our Grievance Officer. If we have reason to believe that there is likely to be a breach of security or misuse of App, we may require you to change your password or we may suspend your account without any liability whatsoever. Further, we reserve the right to suspend or terminate your User Account if, at our sole discretion, we have grounds to believe that your use of App seriously and repeatedly breaches the Terms of Use. We may also suspend or terminate your User Account upon a lawful request of a public authority.\n\n"
                    "3.6. You also agree and confirm that you will:\n"
                    "• provide accurate, current and complete information whenever prompted by the App or when required by the App’s registration form (“Registration Data”).\n"
                    "• maintain and promptly update the Registration Data to keep it accurate, current and complete at all times. If you provide any information that is untrue, inaccurate, incomplete, or not current or if we have reasonable grounds to suspect that such information is not in accordance with the Terms of Use (whether wholly or in part thereof), we reserve the right to reject your registration and/or indefinitely suspend or terminate your membership and refuse to use the App.\n"
                    "• indemnify and keep us indemnified from and against all claims resulting from the use of any detail/information/ Registration Data that you post and/or supply to us. We shall be entitled to remove any such detail/information/Registration Data posted by you without any prior information.",
                textColor, bodyColor
            ),

            _buildSection(
                "4. Fees and Payment Terms",
                "4.1. Your use of App is subject to the applicable service fees (the “Fees”). The Fees and payment terms related thereto are communicated by us to you personally, upon your request, by email or phone. The Fees shall be charged in United State dollars (USD) currency. The Fees are charged automatically on a monthly basis, until you stop your subscription. By purchasing a subscription to use App, you agree to pay the Fees upon these Terms. The Fees are subject to a change without a prior notice. Any changes to the Fees will be made available to you and, if necessary, we will request you to provide your consent to the changes of the Fees.\n\n"
                    "4.2. All Fees are exclusive of all taxes, levies, or duties imposed by taxing authorities. Unless otherwise stated in the schedule of the Fees, you are responsible for paying all applicable taxes.\n\n"
                    "4.3. You shall be entitled to use a valid credit/debit and/or any other payment cards (“Virtual Payment Modes”) which shall be processed by our third-party payment processor (“Payment Processor”) for payments including the Fees and the payments made by the Clients. The Payment Processor is solely responsible for handling your payments. You agree not to hold us liable for payments that do not reach us because you have quoted incorrect payment information or the Payment Processor refused the payment for any other reason. The Payment Processor may collect from you some personal data, which will allow them to make the payments requested by you (e.g., your name, and credit card details). The Payment Processor handles all the steps in the payment process on its website, including data collection and data processing. We do not store your credit card details in our systems.\n\n"
                    "4.4. You agree and accept that all nuances and modalities relating to Virtual Payment Modes shall be separately governed by the Payment Processor. We would not be responsible, in any manner whatsoever, for any liability that may arise in relation to any aspect of/ relating to the Virtual Payment Modes (including any fraudulent transaction). The payments made on the App are non-refundable.\n\n"
                    "4.5. We will not be liable for the loss of any nature whatsoever caused to you arising, directly or indirectly, out of decline of authorization for any transaction, resulting from you exceeding your pre-set permissible payment limit under Virtual Payment modes, as applicable.",
                textColor, bodyColor
            ),

            _buildSection(
                "5. Availability",
                "5.1. We will take all reasonable efforts to ensure that our services on App are operational and uninterrupted. In case of certain technical difficulties, routine site maintenance/upgrades and any other event outside our control may, from time to time, result in temporary service interruptions. We also reserve the right at any time and from any time to modify, suspend or discontinue, temporarily or permanently, the App or any part thereof with or without notice. You agree that we shall not be liable to you or any third party for any of the direct or indirect consequences of any modification, suspension, discontinuance of or interruption to the use / access to App.",
                textColor, bodyColor
            ),

            _buildSection(
                "6. User Content",
                "6.1. We may allow you to create, post, share, upload and submit the Content on or through the App (“User Content”). You will be entitled to own the rights in such User Content. The User shall be solely responsible for the User Content and assume all risks associated with it, without any limitation.\n\n"
                    "6.2. By submitting or uploading or posting User Content, you grant us a non-exclusive, worldwide, perpetual, irrevocable, royalty-free, sub-licensable right to copy and store User Content as a back-up in our systems. We shall not distribute, publish or process the User Content to any third-party unless required under the law. You will ensure that your Content does not violate the Terms of use and other applicable laws including all intellectual property rights associated therewith.\n\n"
                    "6.3. You are responsible for your use of the Services, for any User Content you provide, and for any consequences thereof, including the use of your User Content by other users and our third-party partners. We will not be responsible or liable for any use of your User Content by us in accordance with these Terms. We do not guarantee any confidentiality with respect to any User Content that you may submit. By submitting or posting the User Content, you represent and warrant that you have full and unrestricted rights, power and authority necessary to grant the rights, granted in relation to any User Content that you submit. You also represent and warrant that the posting of your User Content or usage of such User Content in accordance with the terms hereof does not violate any right of any party, including copyrights, privacy rights, publicity rights, trademarks, contract rights, or any other intellectual property rights.\n\n"
                    "6.4. The Trainer in order to ensure the security of the App, may (but have no obligation to)monitor or review Your Content. We reserve the right, at our sole discretion, to refuse to upload, modify, delete, or remove Your Content, in whole or in part, that violates the Terms of Use or may harm the reputation and goodwill of App. However, you remain solely responsible for Your Content. You may delete your User Content or User Account at any time.\n\n"
                    "6.5. You are not permitted to disclose publicly, the personal data of persons without their prior authorization or consent to share that personal data (e.g., you cannot publish name, photos, videos, and contact details of a person who has not allowed you to do so) through Your Content.",
                textColor, bodyColor
            ),

            _buildSection(
                "7. Other Representations, Warranties and Covenants",
                "7.1. You understand and undertake that you shall be solely responsible for the Registration Data and the User Content and undertake neither by yourself nor by permitting any third party to host, display, upload, modify, publish, transmit, update or share any information that:\n"
                    "• belongs to another person and to which you do not have any right to;\n"
                    "• is grossly harmful, harassing, blasphemous, defamatory, obscene, pornographic, pedophilic, seditious, libelous, invasive of another's privacy, hateful, or racially, ethnically objectionable, disparaging, relating or encouraging money laundering or gambling, or otherwise unlawful in any manner whatever;\n"
                    "• harms minors in any way;\n"
                    "• infringes any patent, trademark, copyright or other proprietary rights of any person anywhere in the world;\n"
                    "• violates any law for the time being in force;\n"
                    "• deceives or misleads the addressee about the origin of such messages or communicates any information which is grossly offensive or menacing in nature;\n"
                    "• impersonates another person;\n"
                    "• contains software viruses or any other computer code, files or programs designed to interrupt, destroy or limit the functionality of any computer resource;\n"
                    "• threatens the unity, integrity, defence, security or sovereignty of India, friendly relations with foreign states, or public order or causes incitement to the commission of any cognizable offence or prevents investigation of any offence or is insulting to any other nation;\n"
                    "• creates liability for the Trainer or cause the Trainer to lose (in whole or in part) the services of the Trainer or other suppliers and/ or Users;\n"
                    "• is in the nature of political campaigning, unsolicited or unauthorized advertising, promotional and/ or commercial solicitation, chain letters, pyramid schemes, mass mailings and/or any form of 'spam' or solicitation; or\n"
                    "• is illegal in any other way.\n\n"
                    "7.2. You agree and understand that the Trainer reserves the right to remove and/or edit such detail / information. If you think that some of the content available on App is inappropriate, infringes the Terms of Use, applicable laws, or your right to privacy, please contact us immediately at briss.carmax@gmail.com and report the content that is, in your opinion, inappropriate. If any content is reported as inappropriate, we will immediately delete such content from App.\n\n"
                    "7.3. You shall not, directly or indirectly attempt to gain unauthorized access App, other Users’ account(s), computer systems and/or networks connected to the App through hacking, phishing, password mining and/or any other means (whether now known or hereafter developed or invented) or obtain any material or information through any means not intentionally made available to User.",
                textColor, bodyColor
            ),

            _buildSection(
                "8. Force Majeure",
                "8.1. We will not be liable for any failure and/or delay on our part in performing any obligation under the Terms of Use and/or for any loss, damage, costs, charges and expenses incurred and/or suffered by you if such failure and/or delay is result of or arising out of a Force Majeure Event, as defined hereunder.\n\n"
                    "8.2. For the purposes of these Terms of Use, “Force Majeure Event” means any event due to any cause beyond the reasonable control of the Trainer, including, without limitation, unavailability of any communication system, sabotage, fire, flood, earthquake, explosion, acts of God, civil commotion, strikes, lockout, and/or industrial action of any kind, breakdown of transportation facilities, riots, insurrection, hostilities whether war be declared or not, acts of government including change in law, governmental orders or restrictions, breakdown and/or hacking of the App, such that it is impossible to perform the obligations under the Terms of Use, or any other cause or circumstances beyond the control of the Trainer hereto which prevents timely fulfillment of obligation of the Trainer hereunder. It is hereby clarified that the failure to make a payment of money by the User will not be considered to be a Force Majeure Event.",
                textColor, bodyColor
            ),

            _buildSection(
                "9. User’s liability",
                "9.1. The User represents and warrants that all the information provided by the User are true, correct and complete and if found to be untrue, incorrect or incomplete, the Trainer has the right to take any action it deems fit in relation to the particular circumstances without any limitations.\n\n"
                    "9.2. The User represents and warrants that the User is fully aware of all the applicable laws particularly governing the use of App and that the User is not violating or attempting to violate any applicable laws.\n\n"
                    "9.3. The User acknowledges and agrees that the Trainer is not liable for any damages caused including bodily injury caused due to use of Services through this App.",
                textColor, bodyColor
            ),

            _buildSection(
                "10. Restriction on use of Content",
                "10.1. The information and Content provided App is an exclusive property of the Trainer and is protected by applicable intellectual property laws. No person shall use, copy, transmit, reproduce, publish, modify, distribute the same or any part of the App without the express permission of the Trainer. The User agrees to use this App in accordance with the Terms of Use.\n\n"
                    "10.2. Further, the User shall not: (i) interfere or attempt to interfere with the proper working of the services or any activities conducted on the App; (ii) take or attempt to take any action that might damage, disable or overburden our infrastructure; (iii) bypass, circumvent or attempt to bypass or circumvent any measures that the Trainer uses to prevent or restrict access to the services and/ or the Content; (iv) run any form of auto-responder or “spam” on the services and/ or the Content; (v) use manual or automated software, devices, or other processes to “crawl” or “spider” any part of the App and/ or the Content, unless the same is done in accordance with the provisions of our robots.txt file; (vi) harvest or scrape any Content from App; (vii) copy, reproduce, decompile, reverse engineer, disassemble, decrypt, or attempt to derive the source code of or underlying ideas or algorithms of any part of the App and/ or Content; (viii) modify, translate, or otherwise create derivative works of any part of the App, (ix) retransmit, distribute, disseminate, sell, perform, make available to third parties, or exploit for any purposes (including, without limitation, personal, non-commercial use) without express prior written consent from us ; or (x) otherwise take any action in violation of our Terms of Use.\n\n"
                    "10.3. The Trainer has the right to access, read, preserve, and disclose any information as it reasonably believes is necessary: (i) under any applicable laws or governmental request, (ii) enforce the Terms of Use, including investigation of potential violations hereof, (iii) detect, prevent, or otherwise address fraud, security or technical issues, (iv) respond to User support requests, or (v) protect its rights, property or safety along with that of its Users and the public.",
                textColor, bodyColor
            ),

            _buildSection(
                "11. Limitation of Liability",
                "11.1. Unless otherwise excluded or limited by the applicable law, we will not be liable for any damages including, but not limited to, incidental, punitive, special or other related damages, arising out or in connection with your use of App or any content made available through App. You agree not to hold us and any of our Trainers / staff members liable in respect of any losses arising out of any event or events beyond our reasonable control.\n\n"
                    "11.2. We will not be liable to you for any indirect or consequential losses, which may be incurred by you, such as:\n"
                    "• Any health issues experienced by you as a result of your use of App, including following any instructions, videos, plans, or other materials provided by the Trainers;\n"
                    "• Direct and indirect loss of profits;\n"
                    "• Loss of goodwill or business reputation;\n"
                    "• Loss of opportunities; and\n"
                    "• Loss of data suffered by you.",
                textColor, bodyColor
            ),

            _buildSection(
                "12. Indemnification",
                "12.1. You agree to indemnify, defend and hold us, our subsidiaries, affiliates, partners, officers, directors, agents, contractors, licensors, service providers, subcontractors, suppliers, interns and employees, and FitBudd harmless from any claim or demand, including attorneys’ fees, made by any third party due to or arising out of your breach of this Terms of Use, your use of App, or your violation of any law or the rights of a third party.",
                textColor, bodyColor
            ),

            _buildSection(
                "13. Geographical Extent",
                "13.1. The App can be accessed in and from all jurisdictions across the world. We make no representation that materials or Content available through our App are appropriate or available for all these jurisdictions.\n\n"
                    "13.2. If You use the App from a country or location apart from the United State of America, you are solely responsible for compliance with necessary laws and regulations for use of the App, in your jurisdiction.",
                textColor, bodyColor
            ),

            _buildSection(
                "14. Intellectual Property Rights",
                "14.1. The Content available through the App may be viewed and used only for your personal, non-commercial use. Except as expressly provided herein, you are not granted any rights or license to patents, copyrights, trade secrets or trademarks with respect to the App, and we reserve all rights not expressly granted hereunder. We do not permit copyright infringing activities and infringement of intellectual property rights on or through the App. We request that you promptly notify us in writing upon your discovery of any unauthorized use or infringement of the App. You agree not to make use of the Content in a manner that would infringe the copyright and trademark therein.\n\n"
                    "14.2. You also acknowledge and agree that any feedback, comment or suggestion you may provide is entirely voluntary and we will be free to use such feedback, comments or suggestions as we see fit and without any obligation or compensation to you.",
                textColor, bodyColor
            ),

            _buildSection(
                "15. Jurisdiction and Applicable Law",
                "15.1. Terms of Use shall be governed by and interpreted and construed in accordance with the laws of USA (“applicable laws” or “laws”). The courts at [∙] shall have exclusive jurisdiction in relation to any proceedings arising out of or in connection with these Terms of Use.",
                textColor, bodyColor
            ),

            _buildSection(
                "16. Complaints and Grievance Redressal",
                "16.1. Any complaints or concerns with regards to content of this App or comment or breach of these Terms of Use or any intellectual property of any user shall be immediately informed to the designated Grievance Officer as mentioned below via email signed with the electronic signature.\n\n"
                    "Name: Brisley\n"
                    "Email: briss.carmax@gmail.com",
                textColor, bodyColor
            ),

            _buildSection(
                "17. Miscellaneous",
                "• No waiver: Even if the Trainer does not exercise a particular right or enforce a particular clause under these Terms of Use, it will not amount to a waiver of the Trainer’s rights under these Terms of Use.\n\n"
                    "• Severability: If any provision of these Terms of Use is found invalid by a court of competent jurisdiction, you agree that the court should try to give effect to the intentions as reflected in the such provision and that the other provisions of the Terms of Use shall remain in full effect, notwithstanding anything contained in such impugned provision. Thus, illegality or unenforceability of one or more Terms of Use shall not affect the legality and enforceability of the other terms of the App.\n\n"
                    "• Term and termination: The Terms of Use enter into force on the date indicated at the top of the Terms of Use and remain in force until updated or terminated by us or until you stop using App.\n\n"
                    "• Amendments: We reserve the right to modify these Terms of Use at any time, effective upon posting of an updated version on App. Such amendments may be necessary due to the changes in the requirements of laws, regulations, new features of App, or our business practices. We will send you a notification (if we have your email address) about any material amendments to the Terms of Use that may be of importance to you. You are responsible for regularly reviewing these Terms of Use. Your continued use of App after any changes shall constitute your consent to such changes. We also reserve the right to modify the services provided through App at any time, at our sole discretion.\n\n"
                    "• Breach of Terms: If we believe, at our sole discretion, that you violate these Terms of Use and it is appropriate, necessary or desirable to do so, we may: Send the User a formal warning; Temporary suspend your User Account; Delete your User Account; Temporarily or permanently prohibit your use of App; Report you to the relevant public authorities; or Commence a legal action against you.\n\n"
                    "• Assignment: You are not allowed to assign your rights under these Terms of Use. We are entitled to transfer our rights and obligations under these Terms of Use entirely or partially to a third party without giving prior notice to you. If you do not agree to the transfer, you can terminate these Terms of Use with immediate effect by deleting the User Account, canceling the Fees, and stopping to use App.\n\n"
                    "• It is clarified that the Disclaimer and the Privacy Policy provided separately form an integral part of these Terms of Use of the App and should be read in conjunction.",
                textColor, bodyColor
            ),

            Divider(thickness: 2, color: dividerColor),
            const SizedBox(height: 20),

            _buildSection(
                "DISCLAIMER",
                "No Warranties\nIn addition to the disclaimers provided in the Terms of Use, it is further provided that this App and all Content are provided on an “as is” and “as available” basis without any representations or warranties, express or implied. “Brisley” (the “Trainer” or “we” or “our” or “us”) make(s) no representations or warranties in relation to this App or the information and materials provided on this App. Without prejudice to the generality of the foregoing, we do not warrant that: this App and/ or the Content will be constantly available, or available at all; or the information on this App and/ or the Content are complete, true, accurate or not misleading.\n\n"
                    "Nothing on this App constitutes, or is meant to constitute, advice of any kind. While we strive to ensure that the information contained in this App is accurate and reliable, we make no warranties or representations as to the accuracy, correctness, reliability or otherwise with respect to such information, and we assume no liability or responsibility for any omission or error in the content of this App. The information and materials contained on this App are subject to change without notice, are provided for general information only and should not be used as a basis for making business or financial decisions.\n\n"
                    "Despite the best efforts of the Trainer to provide accurate information on the App, it is not possible to ensure that all the information provided here is up to date. The App hosts information and Content provided by third parties and we are in no manner responsible for the accuracy, legitimacy and truthfulness of the information so hosted. You agree to not hold us liable for the incorrectness of any such provided information. Any advice or information received through this App should not be relied upon without consulting primary, accurate and up-to-date sources of information or specific professional advice. The Contents available on this App are protected by copyright law. You may not otherwise change, reproduce, modify, distribute, publicly display the materials available on this App in any way, unless authorized by us or the respective copyright owner(s).",
                textColor, bodyColor
            ),

            _buildSection(
                "Limitations of Liability",
                "We will not be liable to you (whether under the law of contact, the law of torts or otherwise) in relation to the Contents of, or use of, or otherwise in connection with, this App:\n"
                    "• to the extent that the App and/ or the Contents are provided free-of-charge, for any direct loss;\n"
                    "• for any indirect, special or consequential loss;\n"
                    "• for any business losses, loss of revenue, income, profits or anticipated savings, loss of contracts or business relationships, loss of reputation or goodwill, or loss or corruption of information or data;\n"
                    "• any errors in or omissions from this App and the Content, including but not limited to technical inaccuracies and typographical errors;\n"
                    "• any third party websites or content therein directly or indirectly accessed through links in this App, including but not limited to any errors in or omissions therefrom;\n"
                    "• your use of this App and/ or the Services;\n"
                    "• or your use of any equipment or software in connection with the App.\n\n"
                    "These limitations of liability apply even if we have been expressly advised of the potential loss. You further acknowledge that FitBudd will not be liable to you.",
                textColor, bodyColor
            ),

            _buildSection(
                "Further Disclaimers",
                "The Contents in the App may be offensive, harmful, objectionable, indecent, unlawful, inaccurate or inappropriate to some people. The Content does not reflect our opinions or policies and we do not endorse any Content on the App. We may, but are not required to, monitor Content, restrict or remove Content, and suspend or delete a User Account that we determine at our sole discretion is inappropriate or for any other reason. Under no circumstances do we assume any responsibility or liability whatsoever for any Content, including but not limited to any errors or omissions in any Content or any loss or damage of any kind incurred as a result of the use of any Content made available through the Services, and you agree to waive any legal or equitable rights or remedies you may have against us with respect to such Content. Any use or reliance on any Content by you through the Services is at your own risk and liability.\n\n"
                    "It is clarified that this Disclaimer and the Privacy Policy provided separately form an integral part of the Terms of Use of the App and should be read in conjunction. Illegality or unenforceability of one or more Terms of Use shall not affect the legality and enforceability of the other terms of the App.\n\n"
                    "Capitalized terms used herein and not defined shall have the meaning assigned to them in the Terms of Use.",
                textColor, bodyColor
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ✅ Helper widget to create bold headings and regular body text with dynamic colors
  Widget _buildSection(String title, String body, Color titleColor, Color bodyColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontSize: title == "TRAINER - TERMS OF USE" || title == "DISCLAIMER" ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
              decoration: (title == "TRAINER - TERMS OF USE" || title == "DISCLAIMER") ? TextDecoration.underline : TextDecoration.none,
              decorationColor: titleColor,
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 12),
        Text(
          body,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: bodyColor,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}