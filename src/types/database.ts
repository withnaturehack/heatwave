/**
 * Database type definitions for Romeo & Juliet app
 * Ensures type safety across all database queries
 */

export interface Profile {
  id: string;
  user_id: string;
  display_name: string | null;
  social_link: string | null;
  main_photo_url: string | null;
  photo2_url: string | null;
  photo3_url: string | null;
  is_complete: boolean;
  basic_information: Record<string, any> | null;
  location_and_future_plans: Record<string, any> | null;
  work_and_life_stage: Record<string, any> | null;
  education_and_intellectual_life: Record<string, any> | null;
  relationship_direction_and_readiness: Record<string, any> | null;
  family_and_children: Record<string, any> | null;
  lifestyle: Record<string, any> | null;
  values_faith_and_culture: Record<string, any> | null;
  political_and_social_outlook: Record<string, any> | null;
  physical_and_attraction: Record<string, any> | null;
  conversation_transcript: Array<{ role: string; content: string }> | null;
  conversation_summary: string | null;
  elevenlabs_conversation_id: string | null;
  voice_conversation_completed: boolean;
  created_at: string;
  updated_at: string;
}

export interface Membership {
  id: string;
  user_id: string;
  status: 'pending' | 'approved' | 'rejected' | 'applied';
  referral_code_used: string | null;
  application_data: Record<string, any> | null;
  applied_at: string;
  approved_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Match {
  id: string;
  user_id: string;
  matched_user_id: string;
  match_score: number | null;
  match_decision: 'pending' | 'approved' | 'rejected' | 'expired';
  compatibility_summary: string | null;
  strengths: string[] | null;
  tensions: string[] | null;
  dealbreakers: string[] | null;
  match_reason: string | null;
  archetype_dynamic: string | null;
  introduced_at: string | null;
  status: 'pending_review' | 'introduced' | 'accepted' | 'declined' | 'expired';
  created_at: string;
  updated_at: string;
}

export interface Message {
  id: string;
  match_id: string;
  sender_id: string;
  content: string;
  read_at: string | null;
  created_at: string;
}
