import { supabase } from "@/lib/supabaseClient";
import { Profile } from "@/types/database";

/**
 * Save a specific profile section to the database
 * @param userId - The user's auth ID
 * @param columnName - The profile column to update (e.g., "basic_information", "lifestyle")
 * @param sectionPayload - The data to save in that column
 * @returns The updated profile row
 * @throws Error with Supabase error details if save fails
 */
export async function saveProfileSection(
  userId: string,
  columnName: string,
  sectionPayload: Record<string, unknown>
): Promise<Profile | null> {
  const payload = { [columnName]: sectionPayload };

  const { data, error } = await supabase
    .from("profiles")
    .update(payload)
    .eq("user_id", userId)
    .select()
    .single();

  if (error) {
    throw new Error(`Failed to save profile section "${columnName}": ${error.message}`);
  }

  return data as Profile | null;
}
