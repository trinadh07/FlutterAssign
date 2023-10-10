import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Blog List'),
        ),
        body: BlogList(),
      ),
    );
  }
}

class BlogList extends StatelessWidget {
  Future<List<Blog>> _fetchBlogs() async {
    final String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
    final String adminSecret = '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

    final response = await http.get(Uri.parse(url), headers: {
      'x-hasura-admin-secret': adminSecret,
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonDataList = json.decode(response.body)['blogs'];
      final List<Blog> blogs = jsonDataList.map((json) => Blog.fromJson(json)).toList();
      return blogs;
    } else {
      throw Exception('Failed to load blogs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Blog>>(
      future: _fetchBlogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final List<Blog> blogs = snapshot.data!;
          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              return ListTile(
                leading: Container(
                width: 100, // Set the desired width
                height: 400, // Set the desired height
                child: Image.network(
                  blog.imageUrl,
                  fit: BoxFit.cover, // Adjust the fit to your preference
                ),
              ),
                title: Text(blog.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetail(blog: blog),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

class BlogDetail extends StatelessWidget {
  final Blog blog;

  BlogDetail({required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(blog.imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              blog.title,
              style: TextStyle(fontSize: 18),
            ),
          ),
          // Add more details or content here if needed
        ],
      ),
    );
  }
}

class Blog {
  final String id;
  final String imageUrl;
  final String title;

  Blog({
    required this.id,
    required this.imageUrl,
    required this.title,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
