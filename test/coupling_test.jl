using Test
using LinearAlgebra
using SummationByPartsOperators

@testset "Coupled Legendre operators" begin
  for T in (Float32, Float64)
    for degree in 1:5
      ymin = T(0)
      ymax = T(2)
      D = legendre_derivative_operator(ymin, ymax, degree+1)

      for N in 1:3
        xmin = T(-1)
        xmax = T(2)
        mesh = UniformMesh1D(xmin, xmax, N)
        cD_continuous = couple_continuosly(D, mesh)
        cD_central    = couple_discontinuosly(D, mesh)
        cD_plus       = couple_discontinuosly(D, mesh, Val(:plus))
        cD_minus      = couple_discontinuosly(D, mesh, Val(:minus))
        for cD in (cD_central, cD_plus, cD_minus) #TODO
        # for cD in (cD_continuous, cD_central, cD_plus, cD_minus)
          print(devnull, cD)
          x = grid(cD)
          @test norm(cD * x.^0) < degree * N * eps(T)
          for k in 1:degree
            @test cD * x.^k ≈ k .* x.^(k-1)
          end
        end
        M = mass_matrix(cD_central)
        @test M ≈ mass_matrix(cD_plus)
        @test M ≈ mass_matrix(cD_minus)
        @test sum(M) ≈ xmax - xmin
        Dp = Matrix(cD_plus)
        Dm = Matrix(cD_minus)
        diss = M * (Dp - Dm)
        @test diss ≈ diss'
        @test maximum(eigvals(Symmetric(diss))) < degree * N * eps(T)
        Dc = Matrix(cD_central)
        res = M * Dc + Dc' * M
        res[1, 1] += 1
        res[end, end] -= 1
        @test norm(res) < degree * 10N * eps(T)
        res = M * Dp + Dm' * M
        res[1, 1] += 1
        res[end, end] -= 1
        @test norm(res) < degree * 10N * eps(T)

        cD1 = couple_discontinuosly(cD_central, mesh)
        cD2 = couple_discontinuosly(D, UniformMesh1D(xmin, xmax, N^2))
        @test grid(cD1) ≈ grid(cD2)
        @test mass_matrix(cD1) ≈ mass_matrix(cD2)
        @test Matrix(cD1) ≈ Matrix(cD2)

        Mcont = mass_matrix(cD_continuous)
        @test sum(Mcont) ≈ xmax - xmin
        # TODO
        # Dcont = Matrix(cD_continuous)
        # res = Mcont * Dcont + Dcont' * Mcont
        # res[1, 1] += 1
        # res[end, end] -= 1
        # @test norm(res) < degree * 10N * eps(T)
      end

      for N in 1:3
        xmin = T(-1)
        xmax = T(2)
        mesh = UniformPeriodicMesh1D(xmin, xmax, N)
        cD_continuous = couple_continuosly(D, mesh)
        cD_central    = couple_discontinuosly(D, mesh)
        cD_plus       = couple_discontinuosly(D, mesh, Val(:plus))
        cD_minus      = couple_discontinuosly(D, mesh, Val(:minus))
        for cD in (cD_central, cD_plus, cD_minus) #TODO
        # for cD in (cD_continuous, cD_central, cD_plus, cD_minus)
          print(devnull, cD)
          x = grid(cD)
          @test norm(cD * x.^0) < degree * N * eps(T)
        end
        M = mass_matrix(cD_central)
        @test M ≈ mass_matrix(cD_plus)
        @test M ≈ mass_matrix(cD_minus)
        @test sum(M) ≈ xmax - xmin
        Dp = Matrix(cD_plus)
        Dm = Matrix(cD_minus)
        diss = M * (Dp - Dm)
        @test diss ≈ diss'
        @test maximum(eigvals(Symmetric(diss))) < degree * N * eps(T)
        Dc = Matrix(cD_central)
        res = M * Dc + Dc' * M
        @test norm(res) < degree * 10N * eps(T)
        res = M * Dp + Dm' * M
        @test norm(res) < degree * 10N * eps(T)

        Mcont = mass_matrix(cD_continuous)
        @test sum(Mcont) ≈ xmax - xmin
        # TODO
        # Dcont = Matrix(cD_continuous)
        # res = Mcont * Dcont + Dcont' * Mcont
        # @test norm(res) < degree * 10N * eps(T)
      end
    end
  end
end
