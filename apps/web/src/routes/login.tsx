import { createFileRoute } from "@tanstack/react-router"

import { LoginForm } from "@/features/auth/components/login-form"

export const Route = createFileRoute("/login")({
  component: LoginPage,
})

function LoginPage() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-sm flex-col justify-center gap-6 px-4 py-12">
      <header className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">Sign in</h1>
        <p className="text-sm text-neutral-600">
          Enter your credentials to continue.
        </p>
      </header>
      <LoginForm />
    </main>
  )
}
