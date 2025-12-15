import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final isAtBottom = (maxScroll - currentScroll) < 50; // 50px threshold

      if (isAtBottom != _isScrolledToBottom) {
        setState(() {
          _isScrolledToBottom = isAtBottom;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimaryDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Chính sách bảo mật',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.27,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.backgroundGreyLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Giới thiệu
                    _buildSectionHeading('Giới thiệu'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Chào mừng bạn đến với chính sách bảo mật của HerbScan. Chính sách này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ thông tin cá nhân của bạn khi sử dụng ứng dụng nhận diện thảo dược. Chúng tôi cam kết bảo vệ quyền riêng tư của bạn và đảm bảo rằng thông tin của bạn được xử lý một cách an toàn và có trách nhiệm.',
                    ),
                    SizedBox(height: 32.h),
                    
                    // Section 2: Thông tin chúng tôi thu thập
                    _buildSectionHeading('Thông tin chúng tôi thu thập'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Chúng tôi có thể thu thập các loại thông tin sau đây khi bạn sử dụng ứng dụng HerbScan: thông tin nhận dạng cá nhân (tên, email, số điện thoại, ảnh đại diện), dữ liệu sử dụng (lịch sử nhận diện thảo dược, thời gian sử dụng, tính năng đã sử dụng), dữ liệu thiết bị (địa chỉ IP, loại thiết bị, hệ điều hành) và thông tin do bạn cung cấp qua các biểu mẫu hoặc tương tác trong ứng dụng.',
                    ),
                    SizedBox(height: 32.h),
                    
                    // Section 3: Sử dụng thông tin
                    _buildSectionHeading('Sử dụng thông tin'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Thông tin của bạn được sử dụng để cung cấp và cải thiện dịch vụ nhận diện thảo dược, cá nhân hóa trải nghiệm của bạn, lưu trữ lịch sử nhận diện, liên lạc với bạn về các cập nhật và tính năng mới, cũng như để đảm bảo an ninh và ngăn chặn gian lận trên nền tảng của chúng tôi.',
                    ),
                    SizedBox(height: 32.h),
                    
                    // Section 4: Chia sẻ dữ liệu
                    _buildSectionHeading('Chia sẻ dữ liệu'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Chúng tôi không bán hoặc cho thuê thông tin cá nhân của bạn. Chúng tôi chỉ có thể chia sẻ thông tin với các đối tác dịch vụ đáng tin cậy (như Firebase, Google Cloud) để hỗ trợ hoạt động của ứng dụng, hoặc khi được pháp luật yêu cầu. Chúng tôi cam kết chỉ chia sẻ thông tin cần thiết và đảm bảo các đối tác tuân thủ các tiêu chuẩn bảo mật tương tự.',
                    ),
                    SizedBox(height: 32.h),
                    
                    // Section 5: Bảo mật dữ liệu
                    _buildSectionHeading('Bảo mật dữ liệu'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Chúng tôi áp dụng các biện pháp bảo mật kỹ thuật và tổ chức tiên tiến để bảo vệ thông tin của bạn khỏi việc truy cập, sử dụng hoặc tiết lộ trái phép. Điều này bao gồm mã hóa dữ liệu, xác thực người dùng, kiểm soát truy cập và giám sát bảo mật thường xuyên.',
                    ),
                    SizedBox(height: 32.h),
                    
                    // Section 6: Quyền của người dùng
                    _buildSectionHeading('Quyền của người dùng'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Bạn có quyền truy cập, sửa đổi hoặc xóa thông tin cá nhân của mình bất cứ lúc nào thông qua cài đặt tài khoản trong ứng dụng. Bạn cũng có quyền yêu cầu xuất dữ liệu hoặc xóa tài khoản của mình. Vui lòng liên hệ với chúng tôi qua email để thực hiện các quyền này.',
                    ),
                    SizedBox(height: 32.h),
                    
                    // Section 7: Thay đổi chính sách
                    _buildSectionHeading('Thay đổi chính sách'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Chính sách bảo mật này có thể được cập nhật theo thời gian để phản ánh các thay đổi trong cách chúng tôi xử lý thông tin hoặc các yêu cầu pháp lý mới. Chúng tôi sẽ thông báo cho bạn về bất kỳ thay đổi quan trọng nào bằng cách đăng chính sách mới trên trang này và gửi thông báo trong ứng dụng.',
                    ),
                    SizedBox(height: 32.h),
                    
                    // Section 8: Thông tin liên hệ
                    _buildSectionHeading('Thông tin liên hệ'),
                    SizedBox(height: 12.h),
                    _buildSectionContent(
                      'Nếu bạn có bất kỳ câu hỏi nào về chính sách bảo mật này, vui lòng liên hệ với chúng tôi qua email tại ',
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Herbscan@gmail.com',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.63,
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            // Button "Tôi đã đọc và đồng ý"
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundCream,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Opacity(
                opacity: _isScrolledToBottom ? 1.0 : 0.3,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(9999.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'Tôi đã đọc và đồng ý',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.backgroundWhite,
                      fontSize: 16.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 22.sp,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.33,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      textAlign: TextAlign.justify,
      style: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 16.sp,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        height: 1.63,
      ),
    );
  }
}
