// import 'package:flutter/material.dart' as material show Icons;
// import 'package:flutter/material.dart' hide Icons;
// import 'package:flutter_svg/flutter_svg.dart';

// import 'assets.dart';

// /// Example widget demonstrating how to use the Assets utility class
// /// This file shows different ways to load and use assets in your Flutter app
// class AssetsExampleWidget extends StatelessWidget {
//   const AssetsExampleWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Assets Usage Examples'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle('Image Assets'),
//             _buildImageExamples(),
            
//             const SizedBox(height: 32),
            
//             _buildSectionTitle('Icon Assets'),
//             _buildIconExamples(),
            
//             const SizedBox(height: 32),
            
//             _buildSectionTitle('SVG Assets'),
//             _buildSvgExamples(),
            
//             const SizedBox(height: 32),
            
//             _buildSectionTitle('Asset Loading with Error Handling'),
//             _buildErrorHandlingExample(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorHandlingExample() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Best Practices for Asset Loading:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             '• Always provide error builders for fallback UI\n'
//             '• Use placeholder builders for loading states\n'
//             '• Handle missing assets gracefully\n'
//             '• Consider caching strategies for network images\n'
//             '• Optimize asset sizes for better performance',
//             style: TextStyle(fontSize: 14),
//           ),
//           const SizedBox(height: 16),
          
//           // Example of robust image loading
//           SizedBox(
//             width: double.infinity,
//             height: 100,
//             child: Image.asset(
//               Assets.images.emptyState,
//               fit: BoxFit.contain,
//               frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
//                 if (wasSynchronouslyLoaded) {
//                   return child;
//                 }
//                 return AnimatedOpacity(
//                   opacity: frame == null ? 0 : 1,
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.easeOut,
//                   child: child,
//                 );
//               },
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey.shade200,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         material.Icons.broken_image_outlined,
//                         size: 32,
//                         color: Colors.grey.shade600,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Image not found',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIconContainer(String assetPath, String label) {
//     return Column(
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Center(
//             child: Image.asset(
//               assetPath,
//               width: 32,
//               height: 32,
//               errorBuilder: (context, error, stackTrace) => const Icon(
//                 material.Icons.broken_image,
//                 size: 32,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12),
//         ),
//       ],
//     );
//   }

//   Widget _buildIconExamples() {
//     return Wrap(
//       spacing: 16,
//       runSpacing: 16,
//       children: [
//         // Google icon for authentication
//         _buildIconContainer(
//           Assets.icons.google,
//           'Google',
//         ),
        
//         // Camera icon for profile picture
//         _buildIconContainer(
//           Assets.icons.camera,
//           'Camera',
//         ),
        
//         // Settings icon for navigation
//         _buildIconContainer(
//           Assets.icons.settings,
//           'Settings',
//         ),
        
//         // Success icon for status
//         _buildIconContainer(
//           Assets.icons.success,
//           'Success',
//         ),
//       ],
//     );
//   }

//   Widget _buildImageExamples() {
//     return Column(
//       children: [
//         // App logo example
//         Container(
//           width: 100,
//           height: 100,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.asset(
//               Assets.images.logo,
//               fit: BoxFit.cover,
//               // Fallback to a default icon if asset is missing
//               errorBuilder: (context, error, stackTrace) => const Icon(
//                 material.Icons.image_not_supported,
//                 size: 50,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         // Profile placeholder example
//         CircleAvatar(
//           radius: 40,
//           backgroundImage: AssetImage(Assets.images.defaultAvatar),
//           onBackgroundImageError: (exception, stackTrace) {
//             // Handle error - could log or show default
//           },
//           child: const Icon(material.Icons.person), // Fallback if image fails
//         ),
        
//         const SizedBox(height: 16),
        
//         // Hero image with custom sizing
//         Container(
//           width: double.infinity,
//           height: 200,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             image: DecorationImage(
//               image: AssetImage(Assets.images.heroImage),
//               fit: BoxFit.cover,
//               onError: (exception, stackTrace) {
//                 // Log error or show placeholder
//               },
//             ),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withOpacity(0.5),
//                 ],
//               ),
//             ),
//             child: const Center(
//               child: Text(
//                 'Hero Image Overlay',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSvgExamples() {
//     return Column(
//       children: [
//         // Login illustration
//         Container(
//           width: double.infinity,
//           height: 200,
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Center(
//             child: SvgPicture.asset(
//               Assets.svgs.loginIllustration,
//               width: 150,
//               height: 150,
//               placeholderBuilder: (context) => Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   material.Icons.image,
//                   size: 50,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         // Brand logo SVG
//         SvgPicture.asset(
//           Assets.svgs.logoSvg,
//           width: 100,
//           height: 100,
//           colorFilter: const ColorFilter.mode(
//             Colors.blue,
//             BlendMode.srcIn,
//           ),
//           placeholderBuilder: (context) => const CircularProgressIndicator(),
//         ),
//       ],
//     );
//   }
// }