/**
 * Equicrew Frontend Configuration
 *
 * This file contains default settings for the eq-frontend deployment.
 * These settings are applied when no user preferences are stored.
 */

/**
 * Default hidden panels in the sidebar.
 * These panels will be hidden by default for new users.
 * Users can still show them via "Edit Sidebar" if needed.
 */
export const EQ_DEFAULT_HIDDEN_PANELS: string[] = [
  // Add panel URL paths to hide by default
  // Examples: "climate", "light", "security", "energy", "map", "logbook", "history"
  "climate",
  "light",
  "security",
];

/**
 * Default panel order in the sidebar.
 * Empty array means use HA's default order.
 */
export const EQ_DEFAULT_PANEL_ORDER: string[] = [];

/**
 * Whether to show advanced options by default.
 */
export const EQ_DEFAULT_SHOW_ADVANCED = false;
