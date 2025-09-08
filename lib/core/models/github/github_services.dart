class GithubService {
  final String token;
  final String owner;
  final String repo;
  final String branch;
  final String sha;

  GithubService({
    required this.token,
    required this.owner,
    required this.repo,
    required this.branch,
    required this.sha,
});
}