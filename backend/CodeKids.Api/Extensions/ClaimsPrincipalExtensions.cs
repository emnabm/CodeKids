using System.Security.Claims;
using CodeKids.Api.Exceptions;

namespace CodeKids.Api.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetParentId(this ClaimsPrincipal principal)
    {
        var claim = principal.FindFirst(ClaimTypes.NameIdentifier) 
                    ?? principal.FindFirst("sub");

        if (claim == null || !Guid.TryParse(claim.Value, out var parentId))
        {
            throw new UnauthorizedException("User identity could not be verified from token.");
        }

        return parentId;
    }
}
