using System.Threading;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis.Tools.Commands;

namespace Microsoft.CodeAnalysis.Tools
{
  internal class Program
  {
    private static async Task<int> Main(string[] args)
    {
      var rootCommand = RootFormatCommand.GetCommand();
      return await rootCommand.Parse(args).InvokeAsync(CancellationToken.None);
    }
  }
}
