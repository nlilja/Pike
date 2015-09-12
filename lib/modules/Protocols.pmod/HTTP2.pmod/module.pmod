//!
//! HTTP/2 protocol.
//!
//! @rfc{7540@}.
//!

constant client_connection_preface = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n";

enum FrameType {
  FRAME_data			= 0,
  FRAME_headers			= 1,
  FRAME_priority		= 2,
  FRAME_rst_stream		= 3,
  FRAME_settings		= 4,
  FRAME_push_promise		= 5,
  FRAME_ping			= 6,
  FRAME_goaway			= 7,
  FRAME_window_update		= 8,
  FRAME_continuation		= 9,
};

enum Flag {
  FLAG_end_stream		= 0x01,
  FLAG_ack			= 0x01,	// SETTINGS and PING only.
  FLAG_end_headers		= 0x04,
  FLAG_padded			= 0x08,
  FLAG_priority			= 0x20,
};

enum Error {
  ERROR_no_error		= 0x00,
  ERROR_protocol_error		= 0x01,
  ERROR_internal_error		= 0x02,
  ERROR_flow_control_error	= 0x03,
  ERROR_settings_timeout	= 0x04,
  ERROR_stream_closed		= 0x05,
  ERROR_frame_size_error	= 0x06,
  ERROR_refused_stream		= 0x07,
  ERROR_cancel			= 0x08,
  ERROR_compression_error	= 0x09,
  ERROR_connect_error		= 0x0a,
  ERROR_enhance_your_calm	= 0x0b,
  ERROR_inadequate_security	= 0x0c,
  ERROR_http_1_1_required	= 0x0d,
};

enum Setting {
  SETTING_header_table_size		= 1,
  SETTING_enable_push			= 2,
  SETTING_max_concurrent_streams	= 3,
  SETTING_initial_window_size		= 4,
  SETTING_max_frame_size		= 5,
  SETTING_max_header_list_size		= 6,
};

//! @rfc{7540:A@}.
constant TLS_CIPHER_SUITE_BLACK_LIST = (<
  SSL.Constants.SSL_null_with_null_null,
  SSL.Constants.SSL_rsa_with_null_md5,
  SSL.Constants.SSL_rsa_with_null_sha,
  SSL.Constants.SSL_rsa_export_with_rc4_40_md5,
  SSL.Constants.SSL_rsa_with_rc4_128_md5,
  SSL.Constants.SSL_rsa_with_rc4_128_sha,
  SSL.Constants.SSL_rsa_export_with_rc2_cbc_40_md5,
  SSL.Constants.SSL_rsa_with_idea_cbc_sha,
  SSL.Constants.SSL_rsa_export_with_des40_cbc_sha,
  SSL.Constants.SSL_rsa_with_des_cbc_sha,
  SSL.Constants.SSL_rsa_with_3des_ede_cbc_sha,
  SSL.Constants.SSL_dh_dss_export_with_des40_cbc_sha,
  SSL.Constants.SSL_dh_dss_with_des_cbc_sha,
  SSL.Constants.SSL_dh_dss_with_3des_ede_cbc_sha,
  SSL.Constants.SSL_dh_rsa_export_with_des40_cbc_sha,
  SSL.Constants.SSL_dh_rsa_with_des_cbc_sha,
  SSL.Constants.SSL_dh_rsa_with_3des_ede_cbc_sha,
  SSL.Constants.SSL_dhe_dss_export_with_des40_cbc_sha,
  SSL.Constants.SSL_dhe_dss_with_des_cbc_sha,
  SSL.Constants.SSL_dhe_dss_with_3des_ede_cbc_sha,
  SSL.Constants.SSL_dhe_rsa_export_with_des40_cbc_sha,
  SSL.Constants.SSL_dhe_rsa_with_des_cbc_sha,
  SSL.Constants.SSL_dhe_rsa_with_3des_ede_cbc_sha,
  SSL.Constants.SSL_dh_anon_export_with_rc4_40_md5,
  SSL.Constants.SSL_dh_anon_with_rc4_128_md5,
  SSL.Constants.SSL_dh_anon_export_with_des40_cbc_sha,
  SSL.Constants.SSL_dh_anon_with_des_cbc_sha,
  SSL.Constants.SSL_dh_anon_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_krb5_with_des_cbc_sha,
  SSL.Constants.TLS_krb5_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_krb5_with_rc4_128_sha,
  SSL.Constants.TLS_krb5_with_idea_cbc_sha,
  SSL.Constants.TLS_krb5_with_des_cbc_md5,
  SSL.Constants.TLS_krb5_with_3des_ede_cbc_md5,
  SSL.Constants.TLS_krb5_with_rc4_128_md5,
  SSL.Constants.TLS_krb5_with_idea_cbc_md5,
  SSL.Constants.TLS_krb5_export_with_des_cbc_40_sha,
  SSL.Constants.TLS_krb5_export_with_rc2_cbc_40_sha,
  SSL.Constants.TLS_krb5_export_with_rc4_40_sha,
  SSL.Constants.TLS_krb5_export_with_des_cbc_40_md5,
  SSL.Constants.TLS_krb5_export_with_rc2_cbc_40_md5,
  SSL.Constants.TLS_krb5_export_with_rc4_40_md5,
  SSL.Constants.TLS_psk_with_null_sha,
  SSL.Constants.TLS_dhe_psk_with_null_sha,
  SSL.Constants.TLS_rsa_psk_with_null_sha,
  SSL.Constants.TLS_rsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_dh_dss_with_aes_128_cbc_sha,
  SSL.Constants.TLS_dh_rsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_dhe_dss_with_aes_128_cbc_sha,
  SSL.Constants.TLS_dhe_rsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_dh_anon_with_aes_128_cbc_sha,
  SSL.Constants.TLS_rsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_dh_dss_with_aes_256_cbc_sha,
  SSL.Constants.TLS_dh_rsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_dhe_dss_with_aes_256_cbc_sha,
  SSL.Constants.TLS_dhe_rsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_dh_anon_with_aes_256_cbc_sha,
  SSL.Constants.TLS_rsa_with_null_sha256,
  SSL.Constants.TLS_rsa_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_rsa_with_aes_256_cbc_sha256,
  SSL.Constants.TLS_dh_dss_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_dh_rsa_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_dhe_dss_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_rsa_with_camellia_128_cbc_sha,
  SSL.Constants.TLS_dh_dss_with_camellia_128_cbc_sha,
  SSL.Constants.TLS_dh_rsa_with_camellia_128_cbc_sha,
  SSL.Constants.TLS_dhe_dss_with_camellia_128_cbc_sha,
  SSL.Constants.TLS_dhe_rsa_with_camellia_128_cbc_sha,
  SSL.Constants.TLS_dh_anon_with_camellia_128_cbc_sha,
  SSL.Constants.TLS_dhe_rsa_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_dh_dss_with_aes_256_cbc_sha256,
  SSL.Constants.TLS_dh_rsa_with_aes_256_cbc_sha256,
  SSL.Constants.TLS_dhe_dss_with_aes_256_cbc_sha256,
  SSL.Constants.TLS_dhe_rsa_with_aes_256_cbc_sha256,
  SSL.Constants.TLS_dh_anon_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_dh_anon_with_aes_256_cbc_sha256,
  SSL.Constants.TLS_rsa_with_camellia_256_cbc_sha,
  SSL.Constants.TLS_dh_dss_with_camellia_256_cbc_sha,
  SSL.Constants.TLS_dh_rsa_with_camellia_256_cbc_sha,
  SSL.Constants.TLS_dhe_dss_with_camellia_256_cbc_sha,
  SSL.Constants.TLS_dhe_rsa_with_camellia_256_cbc_sha,
  SSL.Constants.TLS_dh_anon_with_camellia_256_cbc_sha,
  SSL.Constants.TLS_psk_with_rc4_128_sha,
  SSL.Constants.TLS_psk_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_psk_with_aes_128_cbc_sha,
  SSL.Constants.TLS_psk_with_aes_256_cbc_sha,
  SSL.Constants.TLS_dhe_psk_with_rc4_128_sha,
  SSL.Constants.TLS_dhe_psk_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_dhe_psk_with_aes_128_cbc_sha,
  SSL.Constants.TLS_dhe_psk_with_aes_256_cbc_sha,
  SSL.Constants.TLS_rsa_psk_with_rc4_128_sha,
  SSL.Constants.TLS_rsa_psk_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_rsa_psk_with_aes_128_cbc_sha,
  SSL.Constants.TLS_rsa_psk_with_aes_256_cbc_sha,
  SSL.Constants.TLS_rsa_with_seed_cbc_sha,
  SSL.Constants.TLS_dh_dss_with_seed_cbc_sha,
  SSL.Constants.TLS_dh_rsa_with_seed_cbc_sha,
  SSL.Constants.TLS_dhe_dss_with_seed_cbc_sha,
  SSL.Constants.TLS_dhe_rsa_with_seed_cbc_sha,
  SSL.Constants.TLS_dh_anon_with_seed_cbc_sha,
  SSL.Constants.TLS_rsa_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_rsa_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_dh_rsa_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_dh_rsa_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_dh_dss_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_dh_dss_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_dh_anon_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_dh_anon_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_psk_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_psk_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_rsa_psk_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_rsa_psk_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_psk_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_psk_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_psk_with_null_sha256,
  SSL.Constants.TLS_psk_with_null_sha384,
  SSL.Constants.TLS_dhe_psk_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_dhe_psk_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_dhe_psk_with_null_sha256,
  SSL.Constants.TLS_dhe_psk_with_null_sha384,
  SSL.Constants.TLS_rsa_psk_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_rsa_psk_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_rsa_psk_with_null_sha256,
  SSL.Constants.TLS_rsa_psk_with_null_sha384,
  SSL.Constants.TLS_rsa_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_dh_dss_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_dh_rsa_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_dhe_dss_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_dhe_rsa_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_dh_anon_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_rsa_with_camellia_256_cbc_sha256,
  SSL.Constants.TLS_dh_dss_with_camellia_256_cbc_sha256,
  SSL.Constants.TLS_dh_rsa_with_camellia_256_cbc_sha256,
  SSL.Constants.TLS_dhe_dss_with_camellia_256_cbc_sha256,
  SSL.Constants.TLS_dhe_rsa_with_camellia_256_cbc_sha256,
  SSL.Constants.TLS_dh_anon_with_camellia_256_cbc_sha256,
  SSL.Constants.TLS_empty_renegotiation_info_scsv,
  SSL.Constants.TLS_ecdh_ecdsa_with_null_sha,
  SSL.Constants.TLS_ecdh_ecdsa_with_rc4_128_sha,
  SSL.Constants.TLS_ecdh_ecdsa_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_ecdh_ecdsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_ecdh_ecdsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_ecdhe_ecdsa_with_null_sha,
  SSL.Constants.TLS_ecdhe_ecdsa_with_rc4_128_sha,
  SSL.Constants.TLS_ecdhe_ecdsa_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_ecdhe_ecdsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_ecdhe_ecdsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_ecdh_rsa_with_null_sha,
  SSL.Constants.TLS_ecdh_rsa_with_rc4_128_sha,
  SSL.Constants.TLS_ecdh_rsa_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_ecdh_rsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_ecdh_rsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_ecdhe_rsa_with_null_sha,
  SSL.Constants.TLS_ecdhe_rsa_with_rc4_128_sha,
  SSL.Constants.TLS_ecdhe_rsa_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_ecdhe_rsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_ecdhe_rsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_ecdh_anon_with_null_sha,
  SSL.Constants.TLS_ecdh_anon_with_rc4_128_sha,
  SSL.Constants.TLS_ecdh_anon_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_ecdh_anon_with_aes_128_cbc_sha,
  SSL.Constants.TLS_ecdh_anon_with_aes_256_cbc_sha,
  SSL.Constants.TLS_srp_sha_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_srp_sha_rsa_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_srp_sha_dss_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_srp_sha_with_aes_128_cbc_sha,
  SSL.Constants.TLS_srp_sha_rsa_with_aes_128_cbc_sha,
  SSL.Constants.TLS_srp_sha_dss_with_aes_128_cbc_sha,
  SSL.Constants.TLS_srp_sha_with_aes_256_cbc_sha,
  SSL.Constants.TLS_srp_sha_rsa_with_aes_256_cbc_sha,
  SSL.Constants.TLS_srp_sha_dss_with_aes_256_cbc_sha,
  SSL.Constants.TLS_ecdhe_ecdsa_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_ecdsa_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_ecdh_ecdsa_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_ecdh_ecdsa_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_ecdhe_rsa_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_rsa_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_ecdh_rsa_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_ecdh_rsa_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_ecdh_ecdsa_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_ecdh_ecdsa_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_ecdh_rsa_with_aes_128_gcm_sha256,
  SSL.Constants.TLS_ecdh_rsa_with_aes_256_gcm_sha384,
  SSL.Constants.TLS_ecdhe_psk_with_rc4_128_sha,
  SSL.Constants.TLS_ecdhe_psk_with_3des_ede_cbc_sha,
  SSL.Constants.TLS_ecdhe_psk_with_aes_128_cbc_sha,
  SSL.Constants.TLS_ecdhe_psk_with_aes_256_cbc_sha,
  SSL.Constants.TLS_ecdhe_psk_with_aes_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_psk_with_aes_256_cbc_sha384,
  SSL.Constants.TLS_ecdhe_psk_with_null_sha,
  SSL.Constants.TLS_ecdhe_psk_with_null_sha256,
  SSL.Constants.TLS_ecdhe_psk_with_null_sha384,
  SSL.Constants.TLS_rsa_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_rsa_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_dh_dss_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_dh_dss_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_dh_rsa_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_dh_rsa_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_dhe_dss_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_dhe_dss_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_dhe_rsa_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_dhe_rsa_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_dh_anon_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_dh_anon_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_ecdhe_ecdsa_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_ecdsa_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_ecdh_ecdsa_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_ecdh_ecdsa_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_ecdhe_rsa_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_rsa_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_ecdh_rsa_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_ecdh_rsa_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_rsa_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_rsa_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_dh_rsa_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_dh_rsa_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_dh_dss_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_dh_dss_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_dh_anon_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_dh_anon_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_ecdh_ecdsa_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_ecdh_ecdsa_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_ecdh_rsa_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_ecdh_rsa_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_psk_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_psk_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_dhe_psk_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_dhe_psk_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_rsa_psk_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_rsa_psk_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_psk_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_psk_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_rsa_psk_with_aria_128_gcm_sha256,
  SSL.Constants.TLS_rsa_psk_with_aria_256_gcm_sha384,
  SSL.Constants.TLS_ecdhe_psk_with_aria_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_psk_with_aria_256_cbc_sha384,
  SSL.Constants.TLS_ecdhe_ecdsa_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_ecdsa_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_ecdh_ecdsa_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_ecdh_ecdsa_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_ecdhe_rsa_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_rsa_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_ecdh_rsa_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_ecdh_rsa_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_rsa_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_rsa_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_dh_rsa_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_dh_rsa_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_dh_dss_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_dh_dss_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_dh_anon_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_dh_anon_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_ecdh_ecdsa_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_ecdh_ecdsa_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_ecdh_rsa_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_ecdh_rsa_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_psk_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_psk_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_rsa_psk_with_camellia_128_gcm_sha256,
  SSL.Constants.TLS_rsa_psk_with_camellia_256_gcm_sha384,
  SSL.Constants.TLS_psk_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_psk_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_dhe_psk_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_dhe_psk_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_rsa_psk_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_rsa_psk_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_ecdhe_psk_with_camellia_128_cbc_sha256,
  SSL.Constants.TLS_ecdhe_psk_with_camellia_256_cbc_sha384,
  SSL.Constants.TLS_rsa_with_aes_128_ccm,
  SSL.Constants.TLS_rsa_with_aes_256_ccm,
  SSL.Constants.TLS_rsa_with_aes_128_ccm_8,
  SSL.Constants.TLS_rsa_with_aes_256_ccm_8,
  SSL.Constants.TLS_psk_with_aes_128_ccm,
  SSL.Constants.TLS_psk_with_aes_256_ccm,
  SSL.Constants.TLS_psk_with_aes_128_ccm_8,
  SSL.Constants.TLS_psk_with_aes_256_ccm_8,

  // Additions from drafts.
  SSL.Constants.SSL_rsa_fips_with_des_cbc_sha,
  SSL.Constants.SSL_rsa_fips_with_3des_ede_cbc_sha,
  SSL.Constants.SSL_rsa_oldfips_with_des_cbc_sha,
  SSL.Constants.SSL_rsa_oldfips_with_3des_ede_cbc_sha,
  SSL.Constants.SSL_rsa_with_rc2_cbc_md5,
  SSL.Constants.SSL_rsa_with_idea_cbc_md5,
  SSL.Constants.SSL_rsa_with_des_cbc_md5,
  SSL.Constants.SSL_rsa_with_3des_ede_cbc_md5,
>);
