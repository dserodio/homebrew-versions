class KubernetesCli14 < Formula
  desc "Kubernetes command-line interface"
  homepage "http://kubernetes.io/"
  url "https://github.com/kubernetes/kubernetes/archive/v1.4.7.tar.gz"
  sha256 "2f5d4c5071109935386c550899ae85f338ee3a9d58cb1908d2d975d8a9c5baa9"

  depends_on "go" => :build

  conflicts_with "kubernetes-cli", :because => "Differing versions of the same formula"

  def install
    if build.stable?
      system "make", "all", "WHAT=cmd/kubectl", "GOFLAGS=-v"
    else
      # avoids needing to vendor github.com/jteeuwen/go-bindata
      rm "./test/e2e/framework/gobindata_util.go"

      ENV.deparallelize { system "make", "generated_files" }
      system "make", "kubectl", "GOFLAGS=-v"
    end
    arch = MacOS.prefer_64_bit? ? "amd64" : "x86"
    bin.install "_output/local/bin/darwin/#{arch}/kubectl"

    output = Utils.popen_read("#{bin}/kubectl completion bash")
    (bash_completion/"kubectl").write output
  end

  test do
    output = shell_output("#{bin}/kubectl 2>&1")
    assert_match "kubectl controls the Kubernetes cluster manager.", output
  end
end
