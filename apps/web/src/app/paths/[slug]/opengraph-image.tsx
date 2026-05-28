import { ImageResponse } from "next/og";
import { packRegistry, getPackBySlug } from "@/lib/content/packs";

/**
 * Dynamically-generated 1200×630 Open Graph image for each pack landing
 * page. Next.js builds one PNG per slug at build time (statically optimized),
 * so social-card previews on Twitter / iMessage / LinkedIn / Slack render
 * a branded card instead of falling back to the site-wide default.
 *
 * Brand: navy background, yellow "PATH" eyebrow, large display title,
 * tagline, lesson-count chip, Numind wordmark.
 */

export const alt = "Numind learning path";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export function generateStaticParams() {
  return packRegistry.map((p) => ({ slug: p.id }));
}

const BRAND_NAVY = "#10224A";
const BRAND_TEAL = "#2DC6B6";
const BRAND_YELLOW = "#FFD84D";
const BRAND_BG_ON_NAVY = "rgba(255, 255, 255, 0.08)";
const BRAND_TEXT_ON_NAVY = "#F6F9FF";
const BRAND_MUTED_ON_NAVY = "rgba(246, 249, 255, 0.72)";

export default async function PathOpenGraphImage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const pack = getPackBySlug(slug);

  // Should never trigger because generateStaticParams enumerates the
  // registry, but defend against drift between this file and packs.ts.
  if (!pack) {
    return new ImageResponse(
      (
        <div
          style={{
            display: "flex",
            width: "100%",
            height: "100%",
            background: BRAND_NAVY,
            color: BRAND_TEXT_ON_NAVY,
            alignItems: "center",
            justifyContent: "center",
            fontSize: 64,
          }}
        >
          Numind
        </div>
      ),
      { ...size },
    );
  }

  return new ImageResponse(
    (
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          width: "100%",
          height: "100%",
          background: BRAND_NAVY,
          padding: "72px 80px",
          color: BRAND_TEXT_ON_NAVY,
          fontFamily:
            "ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
          position: "relative",
        }}
      >
        {/* Subtle teal accent line top-left → bottom-right */}
        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            width: 14,
            height: "100%",
            background: BRAND_TEAL,
          }}
        />

        {/* Eyebrow row: PATH label + Numind wordmark right-aligned */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: 32,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 14,
            }}
          >
            <div
              style={{
                width: 14,
                height: 14,
                borderRadius: 999,
                background: BRAND_YELLOW,
              }}
            />
            <div
              style={{
                fontSize: 22,
                fontWeight: 700,
                letterSpacing: 4,
                color: BRAND_YELLOW,
                textTransform: "uppercase",
              }}
            >
              Numind Path
            </div>
          </div>

          <div
            style={{
              fontSize: 24,
              fontWeight: 700,
              color: BRAND_TEXT_ON_NAVY,
              letterSpacing: -0.2,
            }}
          >
            numind.app
          </div>
        </div>

        {/* Spacer that pushes title block toward the vertical middle */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "center" }}>
          <div
            style={{
              fontSize: 84,
              fontWeight: 800,
              lineHeight: 1.05,
              letterSpacing: -2,
              color: BRAND_TEXT_ON_NAVY,
              display: "flex",
              maxWidth: "92%",
            }}
          >
            {pack.title}
          </div>

          <div
            style={{
              marginTop: 24,
              fontSize: 32,
              fontWeight: 500,
              lineHeight: 1.25,
              color: BRAND_MUTED_ON_NAVY,
              display: "flex",
              maxWidth: "86%",
            }}
          >
            {pack.tagline}
          </div>
        </div>

        {/* Bottom row: chips */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 16,
            marginTop: 24,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              padding: "14px 24px",
              background: BRAND_BG_ON_NAVY,
              borderRadius: 999,
              fontSize: 22,
              fontWeight: 600,
              color: BRAND_TEXT_ON_NAVY,
            }}
          >
            {pack.lessonIds.length} lessons
          </div>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              padding: "14px 24px",
              background: BRAND_BG_ON_NAVY,
              borderRadius: 999,
              fontSize: 22,
              fontWeight: 600,
              color: BRAND_TEXT_ON_NAVY,
            }}
          >
            ~{pack.estimatedMinutes} min
          </div>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              padding: "14px 24px",
              background: BRAND_TEAL,
              borderRadius: 999,
              fontSize: 22,
              fontWeight: 700,
              color: BRAND_NAVY,
            }}
          >
            Take the path →
          </div>
        </div>
      </div>
    ),
    { ...size },
  );
}
