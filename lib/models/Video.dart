class Video {
  final int id;
  final String video_name;
  final String video_description;
  final int video_status;
  final String video_uploaded_filename;
  final String video_range;
  final int video_length;
  final String video_exercise_time;

  Video(
      {required this.video_length,
      required this.video_exercise_time,
      required this.video_name,
      required this.video_description,
      required this.video_status,
      required this.video_uploaded_filename,
      required this.video_range,
      required this.id});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      video_name: json['video_name'],
      video_description: json['video_description'],
      video_status: json['video_description'],
      video_uploaded_filename: json['video_uploaded_filename'],
      video_range: json['video_range']['range_name'],
      video_length: json['video_length'],
      video_exercise_time: json['video_exercise_time'],
    );
  }
}
