import { Link, createFileRoute } from "@tanstack/react-router"

import { SignupForm } from "@/features/auth/components/signup-form"

export const Route = createFileRoute("/signup")({
  component: SignupPage,
})

function SignupPage() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-sm flex-col justify-center gap-6 px-4 py-12">
      <Link
        to="/"
        className="self-start text-sm text-neutral-500 hover:text-neutral-900"
      >
        ← Back
      </Link>
      <header className="space-y-1">
        <h1 className="text-2xl font-semibold tracking-tight">
          Create account
        </h1>
        <p className="text-sm text-neutral-600">
          Already have an account?{" "}
          <Link
            to="/login"
            className="font-medium underline underline-offset-4"
          >
            Sign in
          </Link>
        </p>
      </header>
      <SignupForm />
    </main>
  )
}
