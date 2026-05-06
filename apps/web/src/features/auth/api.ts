import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import { ApiError, apiClient } from "@/lib/api-client"

export type User = {
  id: number
  email_address: string
  created_at: string
}

export type LoginInput = {
  email_address: string
  password: string
}

export const meQueryKey = ["me"] as const

export function useMe() {
  return useQuery({
    queryKey: meQueryKey,
    queryFn: async () => {
      try {
        return await apiClient.get<User>("/me")
      } catch (error) {
        if (error instanceof ApiError && error.status === 401) {
          return null
        }
        throw error
      }
    },
  })
}

export function useLogin() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (input: LoginInput) => apiClient.post<User>("/session", input),
    onSuccess: (user) => {
      queryClient.setQueryData(meQueryKey, user)
    },
  })
}

export function useLogout() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: () => apiClient.delete<void>("/session"),
    onSuccess: () => {
      queryClient.setQueryData(meQueryKey, null)
    },
  })
}
