import type { TemplateResult } from "lit";
import { css, LitElement, html } from "lit";
import { customElement } from "lit/decorators";

@customElement("ha-logo-svg")
export class HaLogoSvg extends LitElement {
  protected render(): TemplateResult {
    // eq Logo: grüner Kreis mit Durchmesser 192, mittig eq-Schriftzug
    return html`<svg
      width="192"
      height="192"
      viewBox="0 0 192 192"
      xmlns="http://www.w3.org/2000/svg"
    >
      <circle cx="96" cy="96" r="96" fill="#38CE7F" />
      <text
        x="50%"
        y="50%"
        font-family="'Arial Black', sans-serif"
        font-size="80"
        font-weight="900"
        fill="#000"
        text-anchor="middle"
        dominant-baseline="middle"
      >
        eq
      </text>
    </svg>`;
  }

  static styles = css`
    :host {
      display: var(--ha-icon-display, inline-flex);
      align-items: center;
      justify-content: center;
      position: relative;
      vertical-align: middle;
      fill: currentcolor;
      width: var(--mdc-icon-size, 24px);
      height: var(--mdc-icon-size, 24px);
    }
    svg {
      width: 100%;
      height: 100%;
      pointer-events: none;
      display: block;
    }
  `;
}
declare global {
  interface HTMLElementTagNameMap {
    "ha-logo-svg": HaLogoSvg;
  }
}
