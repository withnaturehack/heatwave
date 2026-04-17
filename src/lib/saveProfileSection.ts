import { supabase } from "@/lib/supabaseClient";

export async function saveProfileSection(
  userId: string,
  columnName: string,
  sectionPayload: Record<string, unknown>
) {
  const payload = { [columnName]: sectionPayload };

  const { error } = await supabase
    .from("profiles")
    .update(payload)
    .eq("user_id", userId);

  if (error) {
    throw new Error(`Failed to save profile section "${columnName}": ${error.message}`);
  }
}