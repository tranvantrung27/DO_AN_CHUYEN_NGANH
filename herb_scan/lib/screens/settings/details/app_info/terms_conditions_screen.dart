import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Điều khoản & Điều kiện',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Giới thiệu
              _buildSectionHeading('1. Giới thiệu'),
              SizedBox(height: 12.h),
              _buildSectionContent(
                'Chào mừng bạn đến với HerbScan - ứng dụng nhận diện thảo dược Việt Nam. Bằng cách truy cập hoặc sử dụng dịch vụ của chúng tôi, bạn đồng ý bị ràng buộc bởi các điều khoản và điều kiện này. Nếu bạn không đồng ý với bất kỳ phần nào của các điều khoản, bạn không được phép truy cập hoặc sử dụng ứng dụng.',
              ),
              SizedBox(height: 32.h),
              
              // Section 2: Quyền sở hữu trí tuệ
              _buildSectionHeading('2. Quyền sở hữu trí tuệ'),
              SizedBox(height: 12.h),
              _buildSectionContent(
                'Ứng dụng HerbScan, bao gồm tất cả nội dung, tính năng, chức năng, cơ sở dữ liệu thảo dược, thuật toán AI và công nghệ nhận diện là tài sản độc quyền của chúng tôi và các nhà cấp phép. Dịch vụ được bảo vệ bởi bản quyền, nhãn hiệu và các luật về sở hữu trí tuệ của Việt Nam và quốc tế. Bạn không được sao chép, phân phối, sửa đổi hoặc tạo ra các sản phẩm phái sinh từ ứng dụng mà không có sự cho phép bằng văn bản của chúng tôi.',
              ),
              SizedBox(height: 32.h),
              
              // Section 3: Tài khoản người dùng
              _buildSectionHeading('3. Tài khoản người dùng'),
              SizedBox(height: 12.h),
              _buildSectionContent(
                'Khi bạn tạo tài khoản với HerbScan, bạn phải cung cấp thông tin chính xác, đầy đủ và cập nhật tại mọi thời điểm. Bạn chịu trách nhiệm bảo mật thông tin đăng nhập của mình và tất cả các hoạt động diễn ra dưới tài khoản của bạn. Việc không tuân thủ các yêu cầu này có thể dẫn đến việc chấm dứt ngay lập tức tài khoản của bạn trên ứng dụng.',
              ),
              SizedBox(height: 32.h),
              
              // Section 4: Sử dụng bị cấm
              _buildSectionHeading('4. Sử dụng bị cấm'),
              SizedBox(height: 12.h),
              _buildSectionContent('Bạn đồng ý không sử dụng ứng dụng HerbScan:'),
              SizedBox(height: 12.h),
              // Bullet points
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(
                      'Để vi phạm bất kỳ luật hoặc quy định hiện hành nào của Việt Nam hoặc quốc tế.',
                    ),
                    SizedBox(height: 12.h),
                    _buildBulletPoint(
                      'Để sử dụng thông tin thảo dược cho mục đích chẩn đoán, điều trị hoặc thay thế cho tư vấn y tế chuyên nghiệp mà không có sự giám sát của bác sĩ.',
                    ),
                    SizedBox(height: 12.h),
                    _buildBulletPoint(
                      'Để mạo danh hoặc cố gắng mạo danh HerbScan, nhân viên của chúng tôi, người dùng khác hoặc bất kỳ cá nhân, tổ chức nào khác.',
                    ),
                    SizedBox(height: 12.h),
                    _buildBulletPoint(
                      'Để truy cập trái phép, can thiệp, phá hoại hoặc làm gián đoạn hoạt động của ứng dụng, máy chủ hoặc mạng kết nối.',
                    ),
                    SizedBox(height: 12.h),
                    _buildBulletPoint(
                      'Để thu thập hoặc lưu trữ dữ liệu cá nhân của người dùng khác mà không có sự cho phép.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              
              // Section 5: Chấm dứt
              _buildSectionHeading('5. Chấm dứt'),
              SizedBox(height: 12.h),
              _buildSectionContent(
                'Chúng tôi có quyền chấm dứt hoặc đình chỉ quyền truy cập vào ứng dụng HerbScan của bạn ngay lập tức, mà không cần thông báo trước hoặc chịu trách nhiệm pháp lý, vì bất kỳ lý do gì, bao gồm nhưng không giới hạn nếu bạn vi phạm các Điều khoản này. Sau khi chấm dứt, quyền sử dụng của bạn sẽ ngay lập tức chấm dứt và bạn phải ngừng sử dụng ứng dụng.',
              ),
              SizedBox(height: 32.h),
              
              // Section 6: Từ chối trách nhiệm y tế
              _buildSectionHeading('6. Từ chối trách nhiệm y tế'),
              SizedBox(height: 12.h),
              _buildSectionContent(
                'Thông tin trong ứng dụng HerbScan chỉ mang tính chất tham khảo và giáo dục. Chúng tôi không cung cấp tư vấn y tế, chẩn đoán hoặc điều trị. Bạn nên luôn tham khảo ý kiến của bác sĩ, dược sĩ hoặc chuyên gia y tế có chuyên môn trước khi sử dụng bất kỳ thảo dược nào. Chúng tôi không chịu trách nhiệm về bất kỳ hậu quả nào phát sinh từ việc sử dụng thông tin trong ứng dụng.',
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 24.sp,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        height: 1.25,
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

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.h, right: 12.w),
          child: Container(
            width: 6.w,
            height: 6.h,
            margin: EdgeInsets.only(top: 6.h),
            decoration: BoxDecoration(
              color: AppColors.textPrimaryDark,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 16.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
          ),
        ),
      ],
    );
  }
}
