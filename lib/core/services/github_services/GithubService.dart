class GithubService {
  final String token;
  final String owner;
  final String repo;
  final String branch;

  GithubService({
    required this.token,
    required this.owner,
    required this.repo,
    required this.branch,
});
}