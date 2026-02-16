abstract class UsersEvent {}

class SearchUsers extends UsersEvent {
  final String query;
  SearchUsers(this.query);
}

class ClearSearch extends UsersEvent {}
