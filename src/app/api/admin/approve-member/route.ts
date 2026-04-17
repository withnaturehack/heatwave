import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";

const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function POST(req: NextRequest) {
  const adminSecret = req.headers.get("x-admin-secret");
  if (adminSecret !== process.env.ADMIN_SECRET) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { applicationId, action } = await req.json();
  if (!applicationId || !["approved", "rejected"].includes(action)) {
    return NextResponse.json({ error: "Invalid request" }, { status: 400 });
  }

  const { data: application, error: fetchError } = await supabaseAdmin
    .from("membership_applications")
    .select("*")
    .eq("id", applicationId)
    .single();

  if (fetchError || !application) {
    return NextResponse.json({ error: "Application not found" }, { status: 404 });
  }

  await supabaseAdmin
    .from("membership_applications")
    .update({ status: action, reviewed_at: new Date().toISOString() })
    .eq("id", applicationId);

  if (action === "approved") {
    const newReferralCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    await supabaseAdmin
      .from("members")
      .insert({
        user_id: application.user_id,
        referral_code: newReferralCode,
        referral_codes_remaining: 3,
      });
  }

  return NextResponse.json({ success: true, action });
}