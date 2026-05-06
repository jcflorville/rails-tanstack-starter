import { Link, createFileRoute } from "@tanstack/react-router"

import { LoginForm } from "@/features/auth/components/login-form"

export const Route = createFileRoute("/login")({
  component: LoginPage,
})

function LoginPage() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-sm flex-col justify-center gap-6 px-4 py-12">
      <Link
        to="/"
        className="self-start text-sm text-neutral-500 hover:text-neutral-900"
      >
        ← Back
      </Link>
      <header className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">Sign in</h1>
        <p className="text-sm text-neutral-600">
          Don&apos;t have an account?{" "}
          <Link
            to="/signup"
            className="font-medium underline underline-offset-4"
          >
            Create one
          </Link>
        </p>
      </header>
      <LoginForm />
    </main>
  )
}
