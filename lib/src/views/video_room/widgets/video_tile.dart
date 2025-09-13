import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class VideoTile extends StatelessWidget {
  final HMSPeer peer;

  const VideoTile({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
    final videoTrack = peer.videoTrack;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha((255 * 0.2).toInt()), width: 1),
      ),
      child: Stack(
        children: [
          // Video view or placeholder
          if (videoTrack != null)
            HMSVideoView(track: videoTrack, matchParent: true)
          else
            Container(
              color: Colors.grey[900],
              child: Icon(Icons.person, size: 40, color: Colors.white70),
            ),

          // Peer name overlay
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: Text(
                peer.name,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // Audio indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: peer.audioTrack?.isMute == true ? Colors.red : Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(peer.audioTrack?.isMute == true ? Icons.mic_off : Icons.mic, size: 16, color: Colors.white),
            ),
          ),

          // You indicator for local peer
          if (peer is HMSLocalPeer)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Text(
                  'You',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
