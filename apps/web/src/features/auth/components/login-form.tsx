import { useRouter } from "@tanstack/react-router"
import { type FormEvent, useState } from "react"

import { Button } from "@/components/ui/button"
import { useLogin } from "@/features/auth/api"
import { ApiError } from "@/lib/api-client"

export function LoginForm() {
  const router = useRouter()
  const login = useLogin()
  const [emailAddress, setEmailAddress] = useState("")
  const [password, setPassword] = useState("")
  const [errorMessage, setErrorMessage] = useState<string | null>(null)

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setErrorMessage(null)

    try {
      await login.mutateAsync({ email_address: emailAddress, password })
      router.navigate({ to: "/" })
    } catch (error) {
      if (error instanceof ApiError) {
        setErrorMessage(error.message)
      } else {
        setErrorMessage("Something went wrong. Try again.")
      }
    }
  }

  return (
    <form className="space-y-4" onSubmit={handleSubmit}>
      <div className="space-y-1">
        <label htmlFor="email" className="text-sm font-medium">
          Email
        </label>
        <input
          id="email"
          type="email"
          autoComplete="email"
          required
          value={emailAddress}
          onChange={(event) => setEmailAddress(event.target.value)}
          className="w-full min-h-11 rounded-md border border-neutral-300 bg-white px-3 text-sm focus:border-neutral-900 focus:outline-none"
        />
      </div>
      <div className="space-y-1">
        <label htmlFor="password" className="text-sm font-medium">
          Password
        </label>
        <input
          id="password"
          type="password"
          autoComplete="current-password"
          required
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          className="w-full min-h-11 rounded-md border border-neutral-300 bg-white px-3 text-sm focus:border-neutral-900 focus:outline-none"
        />
      </div>
      {errorMessage && (
        <p role="alert" className="text-sm text-red-600">
          {errorMessage}
        </p>
      )}
      <Button type="submit" disabled={login.isPending} className="w-full">
        {login.isPending ? "Signing in…" : "Sign in"}
      </Button>
    </form>
  )
}
