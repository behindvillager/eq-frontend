import type { HomeAssistant } from "../types";

export const documentationUrl = (_hass: HomeAssistant, path: string) =>
  `https://www.equicrew.com${path}`;
