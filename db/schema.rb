# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130108091644) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "agents", :force => true do |t|
    t.integer  "agent_id"
    t.string   "title"
    t.integer  "foreign_id"
    t.string   "juristic_name"
    t.string   "juristic_address_city"
    t.string   "juristic_address_street"
    t.string   "juristic_address_home"
    t.string   "physical_address_city"
    t.string   "physical_address_district"
    t.string   "physical_address_subway"
    t.string   "physical_address_street"
    t.string   "physical_address_home"
    t.string   "contact_name"
    t.string   "contact_info"
    t.string   "director_name"
    t.string   "director_contact_info"
    t.string   "bookkeeper_name"
    t.string   "bookkeeper_contact_info"
    t.string   "inn"
    t.string   "support_phone"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "collections", :force => true do |t|
    t.integer  "agent_id"
    t.integer  "terminal_id"
    t.integer  "source",                                                 :default => 0,    :null => false
    t.boolean  "reset_counters",                                         :default => true, :null => false
    t.integer  "foreign_id"
    t.decimal  "payments_sum",            :precision => 38, :scale => 2
    t.integer  "payments_count"
    t.decimal  "receipts_sum",            :precision => 38, :scale => 2
    t.decimal  "approved_payments_sum",   :precision => 38, :scale => 2
    t.integer  "approved_payments_count"
    t.decimal  "cash_sum",                :precision => 38, :scale => 2
    t.integer  "cash_payments_count"
    t.integer  "cashless_payments_count"
    t.text     "banknotes"
    t.text     "session_ids"
    t.datetime "collected_at"
    t.datetime "hour"
    t.date     "day"
    t.date     "month"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
  end

  create_table "commission_sections", :force => true do |t|
    t.integer  "commission_id"
    t.integer  "agent_id"
    t.integer  "terminal_id"
    t.integer  "payment_type"
    t.decimal  "min",           :precision => 38, :scale => 2
    t.decimal  "max",           :precision => 38, :scale => 2
    t.decimal  "percent_fee",   :precision => 38, :scale => 2, :default => 0.0, :null => false
    t.decimal  "static_fee",    :precision => 38, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  create_table "commissions", :force => true do |t|
    t.integer  "provider_profile_id"
    t.date     "start"
    t.date     "finish"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "gateway_attachments", :force => true do |t|
    t.integer  "gateway_id"
    t.string   "keyword"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "gateway_settings", :force => true do |t|
    t.integer  "gateway_id"
    t.string   "keyword"
    t.text     "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "gateway_settings", ["gateway_id", "keyword"], :name => "index_gateway_settings_on_gateway_id_and_keyword"

  create_table "gateway_switches", :force => true do |t|
    t.integer  "gateway_id"
    t.string   "keyword"
    t.boolean  "value",      :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "gateways", :force => true do |t|
    t.string   "title"
    t.string   "keyword"
    t.string   "payzilla"
    t.boolean  "requires_revisions_moderation", :default => false, :null => false
    t.integer  "debug_level",                   :default => 0,     :null => false
    t.boolean  "enabled",                       :default => true,  :null => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  create_table "limit_sections", :force => true do |t|
    t.integer  "limit_id"
    t.integer  "agent_id"
    t.integer  "terminal_id"
    t.integer  "payment_type"
    t.decimal  "min",          :precision => 38, :scale => 2
    t.decimal  "max",          :precision => 38, :scale => 2
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "limits", :force => true do |t|
    t.integer  "provider_profile_id"
    t.date     "start"
    t.date     "finish"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "payments", :force => true do |t|
    t.string   "session_id"
    t.integer  "foreign_id"
    t.integer  "agent_id"
    t.integer  "terminal_id"
    t.integer  "gateway_id"
    t.integer  "provider_id"
    t.integer  "corrected_payment_id"
    t.integer  "user_id"
    t.integer  "collection_id"
    t.integer  "revision_id"
    t.integer  "payment_type"
    t.boolean  "offline",                                             :default => false, :null => false
    t.string   "account"
    t.text     "fields"
    t.text     "raw_fields"
    t.text     "meta"
    t.string   "currency",                                            :default => "rur", :null => false
    t.decimal  "paid_amount",          :precision => 38, :scale => 2
    t.decimal  "commission_amount",    :precision => 38, :scale => 2
    t.decimal  "enrolled_amount",      :precision => 38, :scale => 2
    t.decimal  "rebate_amount",        :precision => 38, :scale => 2
    t.string   "state",                                               :default => "new", :null => false
    t.integer  "gateway_error"
    t.string   "gateway_provider_id"
    t.string   "gateway_payment_id"
    t.datetime "hour"
    t.date     "day"
    t.date     "month"
    t.integer  "source",                                              :default => 0,     :null => false
    t.string   "receipt_number"
    t.datetime "paid_at"
    t.string   "card_number"
    t.string   "card_number_hash"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  add_index "payments", ["agent_id"], :name => "index_payments_on_agent_id"
  add_index "payments", ["created_at"], :name => "index_payments_on_created_at"
  add_index "payments", ["gateway_id"], :name => "index_payments_on_gateway_id"
  add_index "payments", ["provider_id"], :name => "index_payments_on_provider_id"
  add_index "payments", ["state"], :name => "index_payments_on_state"
  add_index "payments", ["terminal_id"], :name => "index_payments_on_terminal_id"

  create_table "provider_fields", :force => true do |t|
    t.integer  "provider_id"
    t.string   "keyword"
    t.string   "title"
    t.string   "kind"
    t.string   "mask"
    t.text     "values"
    t.integer  "priority"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "provider_gateways", :force => true do |t|
    t.integer  "provider_id"
    t.integer  "gateway_id"
    t.integer  "priority"
    t.string   "gateway_provider_id"
    t.string   "account_mapping"
    t.text     "fields_mapping"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "provider_groups", :force => true do |t|
    t.string   "title"
    t.string   "icon"
    t.integer  "provider_group_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "provider_profiles", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "provider_rebates", :force => true do |t|
    t.integer  "rebate_id"
    t.integer  "provider_id"
    t.boolean  "requires_commission"
    t.integer  "payment_type"
    t.decimal  "min",                 :precision => 38, :scale => 2
    t.decimal  "max",                 :precision => 38, :scale => 2
    t.decimal  "min_percent_amount",  :precision => 38, :scale => 2, :default => 0.0, :null => false
    t.decimal  "percent_fee",         :precision => 38, :scale => 2
    t.decimal  "static_fee",          :precision => 38, :scale => 2
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
  end

  create_table "provider_receipt_templates", :force => true do |t|
    t.boolean  "system",     :default => false, :null => false
    t.text     "template"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "providers", :force => true do |t|
    t.integer  "provider_profile_id"
    t.integer  "provider_group_id"
    t.string   "title"
    t.string   "keyword"
    t.string   "juristic_name"
    t.string   "inn"
    t.boolean  "requires_print",               :default => true, :null => false
    t.integer  "foreign_id"
    t.integer  "provider_gateways_count",      :default => 0
    t.string   "icon"
    t.integer  "provider_receipt_template_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "providers", ["keyword"], :name => "index_providers_on_keyword", :unique => true
  add_index "providers", ["updated_at"], :name => "index_providers_on_updated_at"

  create_table "rebates", :force => true do |t|
    t.integer  "gateway_id"
    t.decimal  "period_fee"
    t.integer  "period_kind"
    t.date     "start"
    t.date     "finish"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "report_results", :force => true do |t|
    t.integer  "rows"
    t.integer  "report_id"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "report_templates", :force => true do |t|
    t.string   "kind"
    t.string   "title"
    t.boolean  "open",         :default => false, :null => false
    t.text     "groupping",    :default => "",    :null => false
    t.text     "fields"
    t.text     "calculations"
    t.string   "sorting"
    t.boolean  "sort_desc",    :default => false, :null => false
    t.text     "conditions"
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "reports", :force => true do |t|
    t.integer  "report_template_id"
    t.integer  "user_id"
    t.date     "start"
    t.date     "finish"
    t.string   "state",              :default => "new", :null => false
    t.text     "error"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "revisions", :force => true do |t|
    t.integer  "gateway_id"
    t.date     "date"
    t.string   "state",                                         :default => "new", :null => false
    t.integer  "error"
    t.decimal  "paid_sum",       :precision => 38, :scale => 2
    t.decimal  "enrolled_sum",   :precision => 38, :scale => 2
    t.decimal  "commission_sum", :precision => 38, :scale => 2
    t.integer  "payments_count"
    t.boolean  "moderated",                                     :default => false, :null => false
    t.string   "data"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  add_index "revisions", ["state"], :name => "index_revisions_on_state"

  create_table "roles", :force => true do |t|
    t.string   "keyword"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "system_receipt_templates", :force => true do |t|
    t.string   "keyword"
    t.text     "template"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "term_prof_provider_groups", :force => true do |t|
    t.integer  "terminal_profile_id"
    t.integer  "provider_group_id"
    t.string   "icon"
    t.integer  "priority",            :default => 1000000
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "terminal_builds", :force => true do |t|
    t.string   "version"
    t.string   "source"
    t.text     "hashes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "terminal_orders", :force => true do |t|
    t.integer  "terminal_id"
    t.string   "keyword"
    t.text     "args"
    t.string   "state",       :default => "new", :null => false
    t.string   "error"
    t.integer  "percent"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "terminal_profile_promotions", :force => true do |t|
    t.integer  "terminal_profile_id"
    t.integer  "provider_id"
    t.integer  "priority"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "terminal_profile_providers", :force => true do |t|
    t.integer  "terminal_profile_id"
    t.integer  "provider_id"
    t.string   "icon"
    t.integer  "priority",            :default => 1000000
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "terminal_profiles", :force => true do |t|
    t.string   "title"
    t.string   "support_phone"
    t.string   "keyword"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "terminals", :force => true do |t|
    t.integer  "agent_id"
    t.integer  "terminal_profile_id"
    t.string   "address"
    t.string   "keyword"
    t.string   "description"
    t.string   "state",                   :default => "unknown"
    t.string   "condition"
    t.datetime "notified_at"
    t.datetime "collected_at"
    t.datetime "issues_started_at"
    t.integer  "foreign_id"
    t.string   "sector"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.string   "schedule"
    t.string   "juristic_name"
    t.string   "contract_number"
    t.string   "manager"
    t.string   "rent"
    t.string   "rent_finish_date"
    t.string   "collection_zone"
    t.string   "check_phone_number"
    t.integer  "printer_error"
    t.integer  "cash_acceptor_error"
    t.integer  "modem_error"
    t.string   "version"
    t.boolean  "has_adv_monitor",         :default => true,      :null => false
    t.integer  "incomplete_orders_count", :default => 0,         :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "terminals", ["agent_id"], :name => "index_terminals_on_agent_id"
  add_index "terminals", ["condition"], :name => "index_terminals_on_condition"
  add_index "terminals", ["keyword"], :name => "index_terminals_on_keyword"
  add_index "terminals", ["state"], :name => "index_terminals_on_state"

  create_table "user_roles", :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.text    "priveleges"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "full_name"
    t.boolean  "root",                   :default => false, :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object_changes"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
