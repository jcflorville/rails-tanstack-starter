import { Link, createFileRoute } from "@tanstack/react-router"

import { useLogout, useMe } from "@/features/auth/api"

export const Route = createFileRoute("/")({
  component: HomeComponent,
})

function HomeComponent() {
  const { data: user, isLoading } = useMe()
  const logout = useLogout()

  return (
    <main className="mx-auto flex min-h-screen max-w-2xl flex-col items-start justify-center gap-6 px-4 py-12">
      <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">
        {"{{PROJECT_NAME}}"}
      </h1>
      <p className="text-lg text-neutral-600">
        Rails 8 API + Vite/React/TanStack monorepo template.
      </p>
      {isLoading ? null : user ? (
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
          <span className="text-sm text-neutral-600">
            Signed in as <strong>{user.email_address}</strong>
          </span>
          <button
            onClick={() => logout.mutate()}
            disabled={logout.isPending}
            className="inline-flex min-h-11 items-center rounded-md border border-neutral-300 px-4 text-sm font-medium text-neutral-900 hover:bg-neutral-100 disabled:opacity-50"
          >
            {logout.isPending ? "Signing out…" : "Sign out"}
          </button>
        </div>
      ) : (
        <Link
          to="/login"
          className="inline-flex min-h-11 items-center rounded-md bg-neutral-900 px-4 text-sm font-medium text-white hover:bg-neutral-800"
        >
          Sign in
        </Link>
      )}
    </main>
  )
}
