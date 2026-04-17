"use client";

import { Suspense, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { supabase } from "@/lib/supabaseClient";
import { AUTH } from "@/config/site";
import { Button, Text, LoadingSpinner } from "@/components/ui";

function AuthCallbackContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [status, setStatus] = useState<"loading" | "error">("loading");

  useEffect(() => {
    const handleCallback = async () => {
      const code = searchParams.get("code");
      if (code) {
        const { error } = await supabase.auth.exchangeCodeForSession(code);
        if (error) {
          console.error("Auth callback error:", error.message);
          setStatus("error");
          return;
        }
      }

      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (session) {
        router.replace("/membership-access");
      } else {
        router.replace("/");
      }
    };

    handleCallback();
  }, [router, searchParams]);

  if (status === "error") {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center px-6 bg-[#fafafa]">
        <Text className="text-red-600 mb-4">{AUTH.signInFailed}</Text>
        <Button variant="ghost" onClick={() => router.replace("/")}>
          {AUTH.backToLogin}
        </Button>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-6 bg-[#fafafa]">
      <LoadingSpinner className="mb-3" />
      <Text className="text-sm text-black/70">{AUTH.signingIn}</Text>
    </div>
  );
}

export default function AuthCallbackPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex flex-col items-center justify-center px-6 bg-[#fafafa]">
          <LoadingSpinner className="mb-3" />
          <Text className="text-sm text-black/70">{AUTH.signingIn}</Text>
        </div>
      }
    >
      <AuthCallbackContent />
    </Suspense>
  );
}
