import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { renderWithQuery } from "@/test/render"

import { LoginForm } from "./login-form"

const mockNavigate = vi.fn()

vi.mock("@tanstack/react-router", () => ({
  useRouter: () => ({ navigate: mockNavigate }),
}))

vi.mock("@/lib/api-client", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@/lib/api-client")>()
  return {
    ...actual,
    apiClient: { get: vi.fn(), post: vi.fn(), delete: vi.fn() },
  }
})

const { apiClient } = await import("@/lib/api-client")

describe("LoginForm", () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it("submits credentials and navigates on success", async () => {
    vi.mocked(apiClient.post).mockResolvedValue({
      id: 1,
      email_address: "alice@example.com",
      created_at: "2026-01-01",
    })

    const user = userEvent.setup()
    renderWithQuery(<LoginForm />)

    await user.type(screen.getByLabelText(/email/i), "alice@example.com")
    await user.type(screen.getByLabelText(/password/i), "password123")
    await user.click(screen.getByRole("button", { name: /sign in/i }))

    await waitFor(() => {
      expect(apiClient.post).toHaveBeenCalledWith("/session", {
        email_address: "alice@example.com",
        password: "password123",
      })
      expect(mockNavigate).toHaveBeenCalledWith({ to: "/" })
    })
  })
})
