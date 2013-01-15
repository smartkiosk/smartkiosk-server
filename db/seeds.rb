require 'seeder'

$seeder = Seeder.new

$seeder.seed_gateways
$seeder.seed_receipt_templates

$seeder.seed_terminal_profiles
$seeder.seed_test_terminals if ENV['SEED_TEST']
$seeder.seed_terminal 'LOCAL'

if ENV['SEED_TEST']
  $seeder.seed_test_providers
  $seeder.seed_test_terminal_profile_promotions
  $seeder.seed_test_payments
end

$seeder.seed_engines