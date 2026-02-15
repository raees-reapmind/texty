import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:texty/blocs/users/user_bloc.dart';
import 'package:texty/blocs/users/users_event.dart';
import 'package:texty/blocs/users/users_state.dart';

class SearchUserScreen extends StatelessWidget {
  const SearchUserScreen({super.key});

  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Search Users")),
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              context.read<UsersBloc>().add(SearchUsers(value));
            },
            decoration: const InputDecoration(
              hintText: "Search by name",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: BlocBuilder<UsersBloc, UsersState>(
              builder: (context, state) {
                if (state is UsersLoaded) {
                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];

                      if (user.uid == currentUid) {
                        return const SizedBox();
                      }

                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        onTap: () {
                          final chatId = generateChatId(
                            currentUid,
                            user.uid,
                          );

                        context.go('/chat/$chatId');
                        },
                      );
                    },
                  );
                }

                return const Center(
                  child: Text("Search users..."),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
