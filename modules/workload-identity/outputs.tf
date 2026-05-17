output "service_accounts" {
  description = "Google service accounts keyed by workload binding name."
  value = {
    for key, account in google_service_account.this : key => {
      email = account.email
      name  = account.name
    }
  }
}
